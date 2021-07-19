//
//  FIRStorage.swift
//  FirebaseQuery
//
//  Created by William on 2019/6/17.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import FirebaseStorage

// MARK: - Storage工具
class FIRStorage: NSObject {
    
    /// 圖片類型
    enum ImageType: String {
        
        var metadata: String { return getMetadata() }
        
        case jpeg = ".jpg"
        case png = ".png"
        
        /// 取得Metadata
        private func getMetadata() -> String {
            switch self {
            case .jpeg: return "image/jpeg"
            case .png: return "image/png"
            }
        }
    }
    
    public static let shared = FIRStorage()
    public static let imageFolder = "Books"

    private let reference = Storage.storage().reference()
    private let maxSize: Int64 = 1024 * 1024
    
    private override init() { super.init() }
}

// MARK: - 主工具
extension FIRStorage {
    
    /// 下載圖片 (記憶體)
    func imageWithName(_ name: String, forFolder fold: String, result: @escaping (Result<Any?, Error>) -> Void) {
        
        reference.child(fold).child(name).getData(maxSize: maxSize) { (data, error) in
            if let error = error { result(.failure(error)); return }
            result(.success(data))
        }
    }
    
    /// 下載圖片 (網址)
    func downloadImageWithName(_ name: String, forFolder fold: String, result: @escaping (Result<URL?, Error>) -> Void) {
        
        reference.child(fold).child(name).downloadURL { (url, error) in
            if let error = error { result(.failure(error)); return }
            result(.success(url))
        }
    }
    
    /// 上傳圖片
    func uploadImageWithName(_ name: String, forFolder fold: String, image: UIImage?, type: ImageType, result: @escaping (Result<StorageMetadata?, Error>) -> Void) -> StorageUploadTask? {
        
        guard let image = image,
              let imageData = imageData(image, withType: type),
              let metadata = Optional.some(StorageMetadata()),
              let nameWithType = Optional.some(name + type.rawValue)
        else {
            return nil
        }
        
        metadata.contentType = type.metadata
        
        let task = reference.child(fold).child(nameWithType).putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error { result(.failure(error)); return }
            result(.success(metadata))
        }
        
        return task
    }
    
    /// 刪除圖片
    func removeImage(withName name: String, forFolder fold: String, type: ImageType, result: @escaping (Bool) -> Void) {
        reference.child(fold).child(name + type.rawValue).delete { (error) in
            if let _ = error { result(false); return }
            result(true)
        }
    }
}

// MARK: - 主工具
extension FIRStorage {
    
    /// 圖片壓縮 -> Data
    private func imageData(_ image: UIImage, withType type: ImageType) -> Data? {
        switch type {
        case .jpeg: return image.jpegData(compressionQuality: 0.5)
        case .png: return image.pngData()
        }
    }
}
