//
//  UtilityWeb.swift
//  URLSessionDemo
//
//  Created by William.Weng on 2020/8/11.
//  Copyright © 2020 William.Weng. All rights reserved.
//

import UIKit

// MARK: - UtilityWeb (單例)
final class UtilityWeb: NSObject {

    private var downloadFinishBlock: ((Result<Data, Error>) -> Void)?
    private var downloadBytesBlock: ((URLDownloadBytesInfo) -> Void)?

    static let shared = UtilityWeb()
    private override init() {}
}

// MARK: - typealias
extension UtilityWeb {
    
    typealias HttpBodyInfomation = (contentType: ContentType, httpBody: Data?)
    typealias URLRequestInfomation = (data: Data?, response: URLResponse?)
    typealias URLRequestJSONInfomation = (value: Any?, response: URLResponse?)
    typealias URLDownloadBytesInfo = (written: Int64, total: Int64)
    typealias UploadFileInfomation = (name: String, data: Data)
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
        case contentType = "Content-Type"
        case authorization = "Authorization"
        case contentDisposition = "Content-Disposition"
    }
}

// MARK: - URLSessionDownloadDelegate
extension UtilityWeb: URLSessionDownloadDelegate {

    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        guard let finishBlock = downloadFinishBlock else { return }
        guard let downloadData = try? Data(contentsOf: location) else { finishBlock(.failure(Utility.MyError.urlDownload)); return }

        finishBlock(.success(downloadData))
    }

    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        guard let downloadBytesBlock = downloadBytesBlock else { return }
        downloadBytesBlock((totalBytesWritten, totalBytesExpectedToWrite))
    }
}

// MARK: - 主程式
extension UtilityWeb {

    /// 送出URL Request => 取得回傳值 (Data) / URLResponse => HTTPURLResponse
    func request(with httpMethod: HttpMethod = .POST, urlString: String, parameters: [String: Any]?, headers: [String: Any]?, httpBodyInfomation: HttpBodyInfomation?, result: @escaping (Result<URLRequestInfomation, Error>) -> Void) {
        
        guard let urlRequest = urlRequestMaker(with: httpMethod, urlString: urlString, parameters: parameters, headers: headers, httpBodyInfomation: httpBodyInfomation) else {
            result(.failure(Utility.MyError.urlFormat)); return
        }

        urlDataTask(with: urlRequest) { (taskResult) in
            switch taskResult {
            case .failure(let error): result(.failure(error))
            case .success(let info): result(.success(info))
            }
        }
    }

    /// 送出URL Request => 取得回傳值 (JSON) / URLResponse => HTTPURLResponse
    func requestJSON(with httpMethod: HttpMethod = .POST, urlString: String, parameters: [String: Any]?, headers: [String: Any]?, httpBodyInfomation: HttpBodyInfomation?, result: @escaping (Result<URLRequestJSONInfomation, Error>) -> Void) {

        request(with: httpMethod, urlString: urlString, parameters: parameters, headers: headers, httpBodyInfomation: httpBodyInfomation) { (jsonResult) in

            switch jsonResult {
            case .failure(let error): result(.failure(error))
            case .success(let info):

                let response = info.response
                let value = Utility.shared.jsonSerialization(with: info.data)
                let jsonInfo: URLRequestJSONInfomation = (value, response)

                result(.success(jsonInfo))
            }
        }
    }

    /// 上傳圖片
    func uploadRequest(with httpMethod: HttpMethod = .POST, urlString: String, mimeType: Utility.MimeType = .png, field: String, parameters: [String: Any]? = nil, fileInfos: [UploadFileInfomation], result: @escaping (Result<URLRequestInfomation, Error>) -> Void) {

        guard let boundary = Optional.some(UtilityWeb.shared.uploadBoundaryMaker()),
              let urlRequest = uplaodRequestMaker(with: httpMethod, urlString: urlString, mimeType: mimeType, field: field, parameters: parameters, fileInfos: fileInfos, boundary: boundary)
        else {
            result(.failure(Utility.MyError.urlFormat)); return
        }

        urlDataTask(with: urlRequest) { (taskResult) in
            switch taskResult {
            case .failure(let error): result(.failure(error))
            case .success(let info): result(.success(info))
            }
        }
    }

    /// 下載檔案 (Data)
    func downloadRequest(urlString: String, downloadBytes: ((URLDownloadBytesInfo) -> Void)?, finish: @escaping (Result<Data, Error>) -> Void) {

        guard let downloadTask = downloadTaskMaker(with: urlString, delegate: self) else { return }

        downloadFinishBlock = finish
        downloadBytesBlock = downloadBytes
        downloadTask.resume()
    }
}

// MARK: - 取得資料 (API)
extension UtilityWeb {

    /// 產生設定完整的URLRequest (HttpMethod / URLString / Parameters / Headers / Content-Type)
    private func urlRequestMaker(with httpMethod: HttpMethod = .GET, urlString: String, parameters: [String: Any]?, headers: [String: Any]?, httpBodyInfomation: HttpBodyInfomation?) -> URLRequest? {

        guard let urlComponents = urlComponentsMaker(with: urlString, parameters: parameters),
              let url = urlComponents.url,
              var urlRequest = Optional.some(URLRequest(url: url))
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
    private func urlDataTask(with request: URLRequest, result: @escaping (Result<URLRequestInfomation, Error>) -> Void) {
                
        let dataTask = urlSessionDataTaskMaker(with: request) { (dataTaskResult) in
            
            switch dataTaskResult {
            case .failure(let error): result(.failure(error))
            case .success(let info): result(.success(info))
            }
        }

        dataTask.resume()
    }

    /// 產生URLSessionDataTask
    private func urlSessionDataTaskMaker(with request: URLRequest, result: @escaping (Result<URLRequestInfomation, Error>) -> Void) -> URLSessionDataTask {
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in

            if let error = error { result(.failure(error)); return }
            let info: URLRequestInfomation = (data, response)

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
    private func downloadTaskMaker(with urlString: String, delegate: URLSessionDownloadDelegate?) -> URLSessionDownloadTask? {
        
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
}

// MARK: - 上傳 (Data)
extension UtilityWeb {
    
    /// 產生相關的URLRequest
    private func uplaodRequestMaker(with httpMethod: HttpMethod = .POST, urlString: String, mimeType: Utility.MimeType = .png, field: String, parameters: [String: Any]? = nil, fileInfos: [UploadFileInfomation], boundary: String) -> URLRequest? {

        guard let url = URL(string: urlString),
              let boundary = Optional.some(uploadBoundaryMaker()),
              let imageDataBody = Optional.some(httpBodyDataMaker(with: mimeType, field: field, parameters: parameters, boundary: boundary, fileInfos: fileInfos))
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
    private func httpBodyDataMaker(with mimeType: Utility.MimeType = .png, field: String, parameters: [String: Any]? = nil, boundary: String, fileInfos: [UploadFileInfomation]) -> Data {

        let startBoundary = "--\(boundary)\r\n"
        let endBoundary = "--\(boundary)--\r\n"

        var fileData = Data()

        if let parameters = parameters {

            for (field, value) in parameters {
                
                let formDataWithName = contentDispositionFormDataMaker(field: field)
                let value = "\(value)\r\n"
                
                fileData.append(Utility.shared.dataMaker(string: startBoundary)!)
                fileData.append(Utility.shared.dataMaker(string: formDataWithName)!)
                fileData.append(Utility.shared.dataMaker(string: value)!)
            }
        }

        fileInfos.forEach { (fileInfo) in
            
            let formDataWithFilename = contentDispositionFormDataMaker(field: field, filename: fileInfo.name)
            let imageContentType = contentTypeMaker(with: mimeType)
            
            fileData.append(Utility.shared.dataMaker(string: startBoundary)!)
            fileData.append(Utility.shared.dataMaker(string: formDataWithFilename)!)
            fileData.append(Utility.shared.dataMaker(string: imageContentType)!)
            fileData.append(fileInfo.data)
            fileData.append(Utility.shared.dataMaker(string: "\r\n")!)
        }

        fileData.append(Utility.shared.dataMaker(string: endBoundary)!)
        
        return fileData
    }
}

// MARK: - 組合參數小工具
extension UtilityWeb {
    
    /// 產生Data的Boundary (使用於開頭&結束的標記) -> \r\n (CRLF)
    private func uploadBoundaryMaker() -> String {
        let boundary = "Boundary+\(arc4random())\(arc4random())"
        return boundary
    }

    /// multipart/form-dat; boundary=jkwehkjwhjkhwelkwe
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
        return "Content-Type: \(imageType.rawValue)\r\n\r\n"
    }
}

