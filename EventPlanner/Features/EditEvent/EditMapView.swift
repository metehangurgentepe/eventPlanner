//
//  EditMapView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 26.08.2023.
//

import SwiftUI
import MapKit
import UIKit

struct EditMapView: UIViewRepresentable {
        @EnvironmentObject var locationManager : LocationManager
        @EnvironmentObject var annotationStore: AnnotationStore
        @State var annotations: AnnotationModel
        @State var isEdited : Bool 
    
        
        typealias UIViewType = MKMapView
        
        func makeUIView(context: Context) -> MKMapView {
            let mapView = MKMapView(frame: .zero)
            mapView.delegate = context.coordinator
            
            let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
            longPressGesture.minimumPressDuration = 1.2
            longPressGesture.delegate = context.coordinator
            mapView.addGestureRecognizer(longPressGesture)
            
            if !isEdited{
                mapView.addAnnotation(annotations.annotation)
                mapView.setRegion(MKCoordinateRegion(center: annotations.annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)), animated: true)
            } else{
                mapView.addAnnotation(annotationStore.annotation!)
                mapView.setRegion(MKCoordinateRegion(center: annotations.annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)), animated: true)
            }
               
          //  mapView.annotations.first
            return mapView
        }
        
        func updateUIView(_ uiView: MKMapView, context: Context) {
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            if !isEdited{
                let region = MKCoordinateRegion(center:annotationStore.annotation?.coordinate ?? annotations.annotation.coordinate, span: span)
                uiView.setRegion(region, animated: true)
                uiView.showsUserLocation = true
                locationManager.stopUpdate()
            } else if isEdited{
                let region = MKCoordinateRegion(center: annotationStore.annotation!.coordinate, span: span)
                uiView.setRegion(region, animated: true)
                uiView.showsUserLocation = true
                locationManager.stopUpdate()
            }
            uiView.isZoomEnabled = true
            uiView.isScrollEnabled = true
        }
        
        func makeCoordinator() -> CoordinatorEdit {
            CoordinatorEdit(self,annotationStore: annotationStore,isEdited: isEdited)
        }
        
        class CoordinatorEdit: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
            var parent: EditMapView
            var annotationStore: AnnotationStore
            var isEdited : Bool
            
            
            init(_ parent: EditMapView,annotationStore: AnnotationStore, isEdited: Bool) {
                self.parent = parent
                self.annotationStore = annotationStore
                self.isEdited = isEdited
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
                    isEdited = true
                    print(isEdited)
                }
                
            }
        }
}

