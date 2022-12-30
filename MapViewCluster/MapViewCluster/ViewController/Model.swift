//
//  Model.swift
//  Example
//
//  Created by William.Weng on 2022/12/28.
//

import MapKit
import WWPrint

final class CoordinateInformation: Codable {
    
    var title: String
    var subTitle: String
    var address: String
    var image: String
    var cluster: String
    var latitude: Double
    var longitude: Double
}

final class ClusterInformation: Codable {
    
    var pinColor: String
    var backgroundColor: String
    var generalImage: String
    var selectedImage: String
}

final class MyPinView: MKMarkerAnnotationView, PinViewReusable {
    
    static var coordinateInfoArray: [CoordinateInformation] = [] {
        
        willSet {
            newValue.forEach { info in
                let coordinate = CLLocationCoordinate2D(latitude: info.latitude, longitude: info.longitude)
                coordinateInfoDictionary["\(coordinate)"] = info
            }
        }
    }
    
    static var clusterInforDictionary: [String: ClusterInformation] = [:]
    
    private static var coordinateInfoDictionary: [String: CoordinateInformation] = [:]
    
    func configure(with annotation: MKAnnotation, useCluster: Bool = false, displayPriority: MKFeatureDisplayPriority = .defaultLow) {
        
        guard let coordinateInfo = Self.coordinateInfoDictionary["\(annotation.coordinate)"],
              let clusterInfo = Self.clusterInforDictionary[coordinateInfo.cluster]
        else {
            return
        }
        
        if useCluster { self.clusteringIdentifier = coordinateInfo.cluster }
        
        let leftView = UIImageView(image: UIImage(named: coordinateInfo.image))
        let rightView = UIButton(type: .close)
        let detailView = UILabel._text(coordinateInfo.address)
         
        self.displayPriority = displayPriority
        self.annotation = annotation
        self._setting(pinColor: UIColor(rgba: clusterInfo.pinColor), backgroundColor: UIColor(rgba: clusterInfo.backgroundColor), glyphType: .image(UIImage(named: clusterInfo.generalImage), UIImage(named: clusterInfo.selectedImage)))
        self._calloutAccessoryView(leftView: leftView, rightView: rightView, detailView: detailView)
        
    }
}
