//
//  AddMapView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 17.07.2023.
//

import SwiftUI
import MapKit
import UIKit

struct AddMapView: UIViewRepresentable {
    @EnvironmentObject var locationManager : LocationManager
    @EnvironmentObject var annotationStore: AnnotationStore
    @State var editAnnotation: Bool
    @State var annotations: AnnotationModel
    
    typealias UIViewType = MKMapView
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.2
        longPressGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(longPressGesture)
        
        
        if let annotation = annotationStore.annotation {
            mapView.addAnnotation(annotation)
            mapView.setRegion(MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)), animated: true)
        }
        mapView.annotations.first
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: span)
        uiView.setRegion(region, animated: true)
        uiView.showsUserLocation = true
        locationManager.stopUpdate()
        
        if let annotation = annotationStore.annotation{
            let region = MKCoordinateRegion(center: annotation.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: span)
            uiView.setRegion(region, animated: true)
        }
        
        uiView.isZoomEnabled = true
        uiView.isScrollEnabled = true
    }
    
    
    
    func makeCoordinator() -> CoordinatorAdd {
        CoordinatorAdd(self,annotationStore: annotationStore)
    }
    
    
    
    
    class CoordinatorAdd: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: AddMapView
        var annotationStore: AnnotationStore
        
        
        init(_ parent: AddMapView,annotationStore: AnnotationStore) {
            self.parent = parent
            self.annotationStore = annotationStore
        }
        
        @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                let mapView = gestureRecognizer.view as! MKMapView
                let touchPoint = gestureRecognizer.location(in: mapView)
                let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
                
                
                // if there is annotation in map, delete first
                mapView.removeAnnotations(mapView.annotations)

                
                // Add your code here to create and add an annotation to the map
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
                
                
                // Create a new LocationAnnotation instance with desired properties
                let pin = AnnotationModel(annotation: annotation)
                
                annotationStore.annotation = pin.annotation
                
                mapView.addAnnotation(annotationStore.annotation!)
            }
            
        }
    }
}
