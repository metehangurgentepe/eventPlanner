//
//  LocationView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 12.07.2023.
//

import SwiftUI
import MapKit
import UIKit

struct DetailMapView: UIViewRepresentable {
    @EnvironmentObject var locationManager : LocationManager
    @State var annotations: AnnotationModel
    
    
    typealias UIViewType = MKMapView
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        let annotation = annotations.annotation
        
        mapView.addAnnotation(annotation)
        
        return mapView
        
    }
    
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
        
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: annotations.annotation.coordinate,span: span)
        uiView.setRegion(region, animated: true)
        
    }
}


