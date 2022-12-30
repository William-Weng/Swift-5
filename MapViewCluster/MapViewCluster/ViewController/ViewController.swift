//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2022/12/28.

import UIKit
import MapKit
import WWPrint

final class ViewController: UIViewController {

    @IBOutlet weak var myMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        let pinView = mapView._reusablePinView(for: annotation) as MyPinView
        pinView.configure(with: annotation, useCluster: true)
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return MKCircleRenderer._build(for: overlay, fillColor: .black.withAlphaComponent(0.3), strokeColor: .red, lineWidth: 1.0)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.removeOverlays(mapView.overlays)
        _ = view._overlay(on: mapView, type: .circle(100))
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        mapView.removeOverlays(mapView.overlays)
    }
}

private extension ViewController {
    
    func initSetting() {
        
        title = "Apple Map"
        navigationController?.navigationBar._transparent()
        myMapView._registerPin(with: MyPinView.self)
        
        initUserCenter()
        initPinCoordinate()
    }
    
    func initUserCenter() {
        
        let latitude = 25.032976
        let longitude = 121.5613502
        
        _ = myMapView._regionCenter(latitude: latitude, longitude: longitude, scaleType: .delta(0.01), delegate: self)
                     ._pin(latitude: latitude, longitude: longitude, title: "Hi", subtitle: "Hello, guy.", overlayType: .circle(50))
    }
    
    func initPinCoordinate() {
        
        MyPinView.coordinateInfoArray = parseCoordinatesJSON(resource: "Coordinates.json", for: [CoordinateInformation].self)
        MyPinView.clusterInforDictionary = parseClustersJSON(resource: "Clusters.json", for: [String: ClusterInformation].self)
        
        MyPinView.coordinateInfoArray.forEach { info in
            _ = myMapView._pin(latitude: info.latitude, longitude: info.longitude, title: info.title, subtitle: info.subTitle, overlayType: .circle(50))
        }
    }
    
    func parseCoordinatesJSON<T: Decodable>(resource: String, for type: [T].Type) -> [T] {
        
        guard let jsonString = FileManager.default._readText(from: Bundle.main.url(forResource: resource, withExtension: nil)),
              let jsonObject = jsonString._jsonObject(),
              let dictionary = jsonObject as? [String: Any],
              let coordinates = dictionary["coordinates"] as? [Any],
              let models = coordinates._jsonClass(for: type.self)
        else {
            return []
        }
        
        return models
    }
    
    func parseClustersJSON<T: Decodable>(resource: String, for type: [String: T].Type) -> [String: T] {
        
        guard let jsonString = FileManager.default._readText(from: Bundle.main.url(forResource: resource, withExtension: nil)),
              let jsonObject = jsonString._jsonObject(),
              let dictionary = jsonObject as? [String: Any],
              let clusters = dictionary["clusters"] as? [String: [String: Any]]
        else {
            return [:]
        }
        
        return clusters._jsonClass(for: [String: T].self)
    }
}

