//
//  Constant.swift
//  Example
//
//  Created by William.Weng on 2022/1/22.
//

import Vision

// MARK: - Utility (單例)
final class Constant: NSObject {}

// MARK: - typealias
extension Constant {
    typealias FeaturePoints = (box: CGRect?, landmarks: [[CGPoint]?])                                                               // [人臉特徵點的數據 => 臉部外框 / 臉上的特徵點](https://www.jianshu.com/p/59b43dbe4fbd)
}

// MARK: - enum
extension Constant {
    
    // [臉上的特徵點部位範圍](https://developer.apple.com/documentation/vision/vnfacelandmarks2d)
    enum FaceLandmarkRegion {
        
        case allPoints
        case faceContour
        case leftEye
        case leftEyebrow
        case leftPupil
        case rightEye
        case rightEyebrow
        case rightPupil
        case nose
        case noseCrest
        case medianLine
        case outerLips
        case innerLips
        
        /// Enum => VNFaceLandmarkRegion2D -> 左眼 / 右眼 / …
        /// - Parameter detectResult: VNFaceObservation
        /// - Returns: VNFaceLandmarkRegion2D?
        func toClass(with detectResult: VNFaceObservation) -> VNFaceLandmarkRegion2D? {
            
            guard let landmarks = detectResult.landmarks else { return nil }
            
            switch self {
            case .allPoints: return landmarks.allPoints
            case .faceContour: return landmarks.faceContour
            case .leftEye: return landmarks.leftEye
            case .leftEyebrow: return landmarks.leftEyebrow
            case .leftPupil: return landmarks.leftPupil
            case .rightEye: return landmarks.rightEye
            case .rightEyebrow: return landmarks.rightEyebrow
            case .rightPupil: return landmarks.rightPupil
            case .nose: return landmarks.nose
            case .noseCrest: return landmarks.noseCrest
            case .medianLine: return landmarks.medianLine
            case .outerLips: return landmarks.outerLips
            case .innerLips: return landmarks.innerLips
            }
        }
    }
    
    /// 自訂錯誤
    enum MyError: Error {
        case notImage
        case notTypeCasting
    }
}
