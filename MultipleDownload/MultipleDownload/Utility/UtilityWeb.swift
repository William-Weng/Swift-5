import UIKit

// MARK: - UtilityWeb (單例)
final class UtilityWeb: NSObject {

    private var downloadFinishBlock: ((Result<URLDownloadFinishInfomation, Error>) -> Void)?        // 下載檔案完成的動作
    private var downloadBytesBlock: ((URLDownloadBytesInfomation) -> Void)?                         // 下載進行中的進度 - 檔案大小
    private var downloadResumeBlock: ((Result<ResumeDownloadDataInfomation, Error>) -> Void)?       // 續傳下載完成的動作

    private var resumeDownloadDataContentLength = -1                                                // 續傳下載的檔案大小 (該段的大小 != 總大小)
    private var resumeDownloadDataContentRange = String()                                           // 續傳下載的檔案總大小 (該檔案的真實大小)

    static let shared = UtilityWeb()
    override init() { super.init() }
}

// MARK: - typealias
extension UtilityWeb {
    
    typealias HttpBodyInfomation = (contentType: ContentType, httpBody: Data?)                      // HTTP Requset的ContentType + Body Data
    typealias URLResponseInfomation = (data: Data?, response: URLResponse?)                         // Response的回傳值 (Data)
    typealias URLResponseJSONInfomation = (value: Any?, response: URLResponse?)                     // Response的回傳值 (JSON)
    typealias URLDownloadBytesInfomation = (written: Int64, total: Int64, taskIdentifier: String)   // 下載檔案的大小相關數值
    typealias URLDownloadFinishInfomation = (data: Data, taskIdentifier: String)                    // 下載檔案的大小相關數值
    typealias UploadImageInfomation = (name: String, image: UIImage)                                // 上傳圖片的資訊 (UIImage)
    typealias UploadFileInfomation = (name: String, data: Data)                                     // 上傳檔案的資訊 (Data)
    typealias ResumeDownloadDataInfomation = (data: Data, length: Int, taskIdentifier: String)      // 續傳下載的檔案相關資訊 (Data)
    typealias ResumeDownloadOffset = (start: Int?, end: Int?)                                       // 續傳下載開始~結束位置設定值 (bytes=0-1024)
}

// MARK: - enum
extension UtilityWeb {
    
    /// [HTTP 請求方法](https://developer.mozilla.org/zh-TW/docs/Web/HTTP/Methods)
    enum HttpMethod: String {
        case GET = "GET"
        case HEAD = "HEAD"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
        case CONNECT = "CONNECT"
        case OPTIONS = "OPTIONS"
        case TRACE = "TRACE"
        case PATCH = "PATCH"
    }

    /// [HTTP Content-Type](https://www.runoob.com/http/http-content-type.html) => Content-Type: application/json
    enum ContentType: String {
        case json = "application/json"
        case formUrlEncoded = "application/x-www-form-urlencoded"
        case formData = "multipart/form-data"
    }

    /// [HTTP標頭欄位](https://zh.wikipedia.org/wiki/HTTP头字段)
    enum HTTPHeaderField: String {
        case acceptRanges = "Accept-Ranges"
        case authorization = "Authorization"
        case contentType = "Content-Type"
        case contentLength = "Content-Length"
        case contentRange = "Content-Range"
        case contentDisposition = "Content-Disposition"
        case date = "Date"
        case lastModified = "Last-Modified"
        case range = "Range"
    }
}

// MARK: - 主程式
extension UtilityWeb {

    /// 送出URL Request => 取得回傳值 (Data) / URLResponse => HTTPURLResponse
    func requestTask(with httpMethod: HttpMethod = .POST, urlString: String, parameters: [String: Any]?, headers: [String: Any]?, httpBodyInfomation: HttpBodyInfomation?, result: @escaping (Result<URLResponseInfomation, Error>) -> Void) -> URLSessionDataTask? {
        
        guard let urlRequest = urlRequestMaker(with: httpMethod, urlString: urlString, parameters: parameters, headers: headers, httpBodyInfomation: httpBodyInfomation) else {
            result(.failure(Utility.MyError.urlFormat)); return nil
        }
        
        let dataTask = urlDataTask(with: urlRequest) { (taskResult) in
            switch taskResult {
            case .failure(let error): result(.failure(error))
            case .success(let info): result(.success(info))
            }
        }
        
        return dataTask
    }

    /// 送出URL Request => 取得回傳值 (JSON) / URLResponse => HTTPURLResponse
    func requestJSONTask(with httpMethod: HttpMethod = .POST, urlString: String, parameters: [String: Any]?, headers: [String: Any]?, httpBodyInfomation: HttpBodyInfomation?, result: @escaping (Result<URLResponseJSONInfomation, Error>) -> Void) -> URLSessionDataTask? {
        
        let dataTask = requestTask(with: httpMethod, urlString: urlString, parameters: parameters, headers: headers, httpBodyInfomation: httpBodyInfomation) { (jsonResult) in

            switch jsonResult {
            case .failure(let error): result(.failure(error))
            case .success(let info):

                let response = info.response
                let value = Utility.shared.jsonSerialization(with: info.data)
                let jsonInfo: URLResponseJSONInfomation = (value, response)

                result(.success(jsonInfo))
            }
        }

        return dataTask
    }

    /// 取得該URL的HEAD資訊 (檔案大小 / 類型 / 上傳日期 …)
    func responseHeaderFieldTask(with urlString: String, field: HTTPHeaderField, result: @escaping (Result<Any?, Error>) -> Void) -> URLSessionDataTask? {
        
        let task = requestTask(with: .HEAD, urlString: urlString, parameters: nil, headers: nil, httpBodyInfomation: nil) { (taskResult) in
            switch taskResult {
            case .failure(let error): wwPrint(error)
            case .success(let info): wwPrint(info.response)

            guard let response = info.response as? HTTPURLResponse,
                  let allHeaderFields = Optional.some(response.allHeaderFields)
            else {
                result(.failure(Utility.MyError.urlFormat)); return
            }

            result(.success(allHeaderFields[field.rawValue]))
            }
        }
        
        return task
    }

    /// 上傳檔案 (Data)
    func uploadFileRequestTask(with httpMethod: HttpMethod = .POST, urlString: String, mimeType: Utility.MimeType = .bin, field: String, parameters: [String: Any]? = nil, fileDatas: [UploadFileInfomation], result: @escaping (Result<URLResponseInfomation, Error>) -> Void) -> URLSessionDataTask? {
        
        guard let boundary = Optional.some(UtilityWeb.shared.uploadBoundaryMaker()),
              let urlRequest = uplaodRequestMaker(with: httpMethod, urlString: urlString, mimeType: mimeType, field: field, parameters: parameters, fileDatas: fileDatas, boundary: boundary)
        else {
            result(.failure(Utility.MyError.urlFormat)); return nil
        }

        let dataTask = urlDataTask(with: urlRequest) { (taskResult) in
            switch taskResult {
            case .failure(let error): result(.failure(error))
            case .success(let info): result(.success(info))
            }
        }
        
        return dataTask
    }

    /// 上傳圖片 (UIImage)
    func uploadImageRequestTask(with httpMethod: HttpMethod = .POST, urlString: String, mimeType: Utility.MimeType = .png, field: String, parameters: [String: Any]? = nil, fileInfos: [UploadImageInfomation], result: @escaping (Result<URLResponseInfomation, Error>) -> Void) -> URLSessionDataTask? {

        guard let fileDatas = Optional.some(imagesDataMaker(with: fileInfos, mimeType: mimeType)),
              !fileDatas.isEmpty
        else {
            result(.failure(Utility.MyError.isEmptyData)); return nil
        }
        
        let uploadTask = uploadFileRequestTask(with: httpMethod, urlString: urlString, mimeType: mimeType, field: field, parameters: parameters, fileDatas: fileDatas) { (fileResult) in
            switch fileResult {
            case .failure(let error): result(.failure(error))
            case .success(let info): result(.success(info))
            }
        }

        return uploadTask
    }

    /// 下載檔案 (Data)
    func downloadRequestTask(urlString: String, delegate: URLSessionDownloadDelegate? = nil, downloadBytes: @escaping ((URLDownloadBytesInfomation) -> Void), finish: @escaping (Result<URLDownloadFinishInfomation, Error>) -> Void) -> URLSessionDownloadTask? {

        guard let downloadTask = downloadTaskMaker(urlString: urlString, delegate: delegate ?? self) else { return nil }
        
        downloadBytesBlock = downloadBytes
        downloadFinishBlock = finish

        return downloadTask
    }

    /// 下載多檔案 - 多任務 (multiple task)
    func multipleDownloadFileTaskMaker(with urlStringArray: [String], downloadBytes: @escaping ((UtilityWeb.URLDownloadBytesInfomation) -> Void), finish: @escaping (Result<UtilityWeb.URLDownloadFinishInfomation, Error>) -> Void) -> [URLSessionDownloadTask] {
        
        let downloadTasks = urlStringArray.compactMap { (urlString) -> URLSessionDownloadTask? in

            let downloadTask = downloadRequestTask(urlString: urlString, downloadBytes: { (byteInfo) in
                downloadBytes(byteInfo)
            }, finish: { (result) in
                finish(result)
            })

            return downloadTask
        }

        return downloadTasks
    }

    /// 斷點續傳下載檔案 (Data) => HTTPHeaderField = Range / ∵ 是一段一段下載 ∴ 自己要一段一段存
    func resumeDownloadRequestTask(with urlString: String, delegateQueue: OperationQueue? = .main, offset: ResumeDownloadOffset = (0, nil), timeoutInterval: TimeInterval = .infinity, result: ((Result<ResumeDownloadDataInfomation, Error>) -> Void)?) -> URLSessionDataTask? {

        guard let url = URL(string: urlString),
              var request = Optional.some(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeoutInterval)),
              let session = Optional.some(urlSessionMaker(delegate: self, delegateQueue: delegateQueue, timeoutInterval: timeoutInterval)),
              let headerValue = resumeDownloadOffsetMaker(offset: offset)
        else {
            return nil
        }

        downloadResumeBlock = result
        request.setValue(headerValue, forHTTPHeaderField: HTTPHeaderField.range.rawValue)

        return session.dataTask(with: request)
    }
}

// MARK: - URLSessionDownloadDelegate
extension UtilityWeb: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        guard let finishBlock = downloadFinishBlock else { return }
        guard let downloadData = try? Data(contentsOf: location) else { finishBlock(.failure(Utility.MyError.urlDownload)); return }

        finishBlock(.success((downloadData, "\(downloadTask)")))
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        guard let downloadBytesBlock = downloadBytesBlock else { return }
        downloadBytesBlock((totalBytesWritten, totalBytesExpectedToWrite, "\(downloadTask)"))
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {}
}

// MARK: - URLSessionDataDelegate
extension UtilityWeb: URLSessionDataDelegate {

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        resumeDownloadDataContentLength = Int(headContentFieldMaker(with: response as? HTTPURLResponse, for: .contentLength) as! String) ?? 0
        resumeDownloadDataContentRange = headContentFieldMaker(with: response as? HTTPURLResponse, for: .contentRange) as! String

        wwPrint(resumeDownloadDataContentRange)
        
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {

        guard let downloadResumeBlock = downloadResumeBlock,
              let dataInfomation: ResumeDownloadDataInfomation = Optional.some((data: data, length: resumeDownloadDataContentLength, taskIdentifier: "\(dataTask)"))
        else {
            return
        }
        
        downloadResumeBlock(.success(dataInfomation))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard let error = error,
              let downloadResumeBlock = downloadResumeBlock
        else {
            return
        }
        
        task.cancel()
        downloadResumeBlock(.failure(error))
    }
}

// MARK: - 取得資料 (API)
extension UtilityWeb {

    /// 產生組合完整的URLRequest (HttpMethod / URLString / Parameters / Headers / Content-Type)
    private func urlRequestMaker(with httpMethod: HttpMethod = .GET, urlString: String, parameters: [String: Any]? = nil, headers: [String: Any]? = nil, httpBodyInfomation: HttpBodyInfomation? = nil) -> URLRequest? {

        guard let urlComponents = urlComponentsMaker(with: urlString, parameters: parameters),
              let url = urlComponents.url,
              var urlRequest = Optional.some(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData))
        else {
            return nil
        }

        urlRequest.httpMethod = httpMethod.rawValue

        if let headers = headers {
            for (key, value) in headers {
                if let encodingValue = Utility.shared.encodingURL(string: value as! String) {
                    urlRequest.addValue(encodingValue, forHTTPHeaderField: key)
                }
            }
        }

        if httpMethod != .GET, let httpBodyInfomation = httpBodyInfomation {
            urlRequest.setValue(httpBodyInfomation.contentType.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
            urlRequest.httpBody = httpBodyInfomation.httpBody
        }

        return urlRequest
    }

    /// 送出URLRequest => 取得資料
    private func urlDataTask(with request: URLRequest, result: @escaping (Result<URLResponseInfomation, Error>) -> Void) -> URLSessionDataTask {
                
        let dataTask = urlSessionDataTaskMaker(with: request) { (dataTaskResult) in
            
            switch dataTaskResult {
            case .failure(let error): result(.failure(error))
            case .success(let info): result(.success(info))
            }
        }
        
        return dataTask
    }

    /// 產生URLSessionDataTask
    private func urlSessionDataTaskMaker(with request: URLRequest, result: @escaping (Result<URLResponseInfomation, Error>) -> Void) -> URLSessionDataTask {
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in

            if let error = error { result(.failure(error)); return }
            let info: URLResponseInfomation = (data, response)

            result(.success(info))
        }

        return dataTask
    }

    /// 產生URLComponents => https://example.com/v1/player?name=中文也會通 (scheme: https, host: example.com, path: /v1/player)
    private func urlComponentsMaker(with urlString: String, parameters: [String: Any]?) -> URLComponents? {
        
        guard var urlComponents = URLComponents(string: urlString) else { return nil }

        urlComponents.queryItems = urlQueryItemsMaker(with: parameters)
        return urlComponents
    }

    /// 處理要傳入的參數 => ["name": "中文也會通", "gender": "公的"] => ?name=中文也會通&gender=公的
    private func urlQueryItemsMaker(with parameters: [String: Any]?) -> [URLQueryItem]? {

        guard let parameters = parameters as? [String: String] else { return nil }

        var queryItems: [URLQueryItem] = []

        for (key, value) in parameters {
            guard let queryItem = Optional.some(URLQueryItem(name: key, value: value)) else { return queryItems }
            queryItems.append(queryItem)
        }

        return queryItems
    }
}

// MARK: - 下載 (Data)
extension UtilityWeb {

    /// 產生下載的Task - URLSession => downloadTask (執行用)
    private func downloadTaskMaker(urlString: String, delegate: URLSessionDownloadDelegate?) -> URLSessionDownloadTask? {
        
        guard let url = URL(string: urlString) else { return nil }
        
        let urlRequest = URLRequest(url: url)
        let urlSession = urlSessionMaker(delegate: delegate)
        let task = urlSession.downloadTask(with: urlRequest)
        
        return task
    }

    /// 產生URLSession (傳輸用)
    private func urlSessionMaker(delegate: URLSessionDownloadDelegate?, delegateQueue: OperationQueue? = .main, timeoutInterval: TimeInterval = .infinity) -> URLSession {

        let configiguration = URLSessionConfiguration.default
        configiguration.timeoutIntervalForRequest = timeoutInterval

        return URLSession(configuration: configiguration, delegate: delegate, delegateQueue: delegateQueue)
    }

    /// 根據回傳的HTTPURLResponse取得檔案的HEAD資訊 (allHeaderFields)
    private func headContentFieldMaker(with response: HTTPURLResponse?, for field: HTTPHeaderField) -> Any? {

        guard let response = response,
              let headerFields = Optional.some(response.allHeaderFields),
              let contentField = headerFields[field.rawValue]
        else {
            return nil
        }

        return contentField
    }
}

// MARK: - 上傳 (Data)
extension UtilityWeb {

    /// 產生相關的URLRequest
    private func uplaodRequestMaker(with httpMethod: HttpMethod = .POST, urlString: String, mimeType: Utility.MimeType = .png, field: String, parameters: [String: Any]? = nil, fileDatas: [UploadFileInfomation], boundary: String) -> URLRequest? {

        guard let url = URL(string: urlString),
              let boundary = Optional.some(uploadBoundaryMaker()),
              let imageDataBody = Optional.some(httpBodyDataMaker(with: mimeType, field: field, parameters: parameters, boundary: boundary, fileDatas: fileDatas))
        else {
            return nil
        }

        var request = URLRequest(url: url)

        request.httpMethod = httpMethod.rawValue
        request.setValue(contentTypeFormDataMaker(boundary: boundary), forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        request.httpBody = imageDataBody
        
        return request
    }

    /// 組合相關上傳檔案的參數
    private func httpBodyDataMaker(with mimeType: Utility.MimeType = .png, field: String, parameters: [String: Any]? = nil, boundary: String, fileDatas: [UploadFileInfomation]) -> Data {

        let startBoundary = "--\(boundary)\r\n"
        let endBoundary = "--\(boundary)--\r\n"

        var uploadFileData = Data()

        if let parameters = parameters {

            for (field, value) in parameters {
                
                let formDataWithName = contentDispositionFormDataMaker(field: field)
                let value = "\(value)\r\n"
                
                uploadFileData.append(Utility.shared.dataMaker(string: startBoundary)!)
                uploadFileData.append(Utility.shared.dataMaker(string: formDataWithName)!)
                uploadFileData.append(Utility.shared.dataMaker(string: value)!)
            }
        }

        fileDatas.forEach { (fileData) in
            
            let formDataWithFilename = contentDispositionFormDataMaker(field: field, filename: fileData.name)
            let imageContentType = contentTypeMaker(with: mimeType)
            
            uploadFileData.append(Utility.shared.dataMaker(string: startBoundary)!)
            uploadFileData.append(Utility.shared.dataMaker(string: formDataWithFilename)!)
            uploadFileData.append(Utility.shared.dataMaker(string: imageContentType)!)
            uploadFileData.append(fileData.data)
            uploadFileData.append(Utility.shared.dataMaker(string: "\r\n")!)
        }

        uploadFileData.append(Utility.shared.dataMaker(string: endBoundary)!)
        
        return uploadFileData
    }

    /// UploadFileInfomation (name: String, image: UIImage) => UploadFileData (name: String, data: Data)
    private func imagesDataMaker(with fileInfos: [UploadImageInfomation], mimeType: Utility.MimeType) -> [UtilityWeb.UploadFileInfomation] {

        let fileDatas: [UtilityWeb.UploadFileInfomation] = fileInfos.compactMap { (info) -> UploadFileInfomation? in

            guard let imageData = Utility.shared.imageDataMaker(info.image, mimeType: mimeType),
                  let imageName = Optional.some(info.name)
            else {
                return nil
            }

            return (name: imageName, data: imageData)
        }

        return fileDatas
    }
}

// MARK: - 組合參數小工具
extension UtilityWeb {

    /// 產生Data的Boundary (使用於開頭&結束的標記) -> \r\n (CRLF)
    private func uploadBoundaryMaker() -> String {
        let boundary = "Boundary+\(arc4random())\(arc4random())"
        return boundary
    }

    /// multipart/form-dat; boundary=<boundary>
    private func contentTypeFormDataMaker(boundary: String) -> String {
        return "multipart/form-data; boundary=\(boundary)"
    }

    /// Content-Disposition: form-data; name=userPhoto\r\n\r\n
    private func contentDispositionFormDataMaker(field: String) -> String {
        return "Content-Disposition: form-data; name=\"\(field)\"\r\n\r\n"
    }

    /// Content-Disposition: form-data; name=userPhoto; filename=1.jpg\r\n
    private func contentDispositionFormDataMaker(field: String, filename: String) -> String {
        return "Content-Disposition: form-data; name=\"\(field)\"; filename=\"\(filename)\"\r\n"
    }

    /// Content-Type: image/png\r\n\r\n
    private func contentTypeMaker(with imageType: Utility.MimeType = .png) -> String {
        return "Content-Type: \(imageType)\r\n\r\n"
    }
    
    /// Range: bytes=0-1024
    private func resumeDownloadOffsetMaker(offset: ResumeDownloadOffset) -> String? {
        
        guard let startOffset = offset.start else { return nil }
        guard let endOffset = offset.end else { return String(format: "bytes=%lld-", startOffset) }

        return String(format: "bytes=%lld-%lld", startOffset, endOffset)
    }
}

// MARK: - 小工具
extension UtilityWeb {
    
    /// 產生登入的UserTokenHeader => {"Authorization":"Bearer 3t8kol3i4r46r8v2qnef9fvrhi3lgm0p"}
    private func userTokenHeaderMaker(_ userToken: String?) -> [String: String]? {
        guard let userToken = userToken else { return nil }
        let headers = [HTTPHeaderField.authorization.rawValue: userToken]
        return headers
    }

    /// 測試用Log訊息
    private func wwParameterLog(httpMethod: HttpMethod = .POST, url: String, parameters: [String: Any]? = nil, headers: [String: Any]? = nil) {
        wwPrint("url = \(url), httpMethod = \(httpMethod.rawValue), parameters = \(String(describing: parameters)), headers = \(String(describing: headers))")
    }
}
