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
   // @EnvironmentObject var locationManager : LocationManager
  //  @State var annotations: AnnotationModel
    @StateObject var viewModel = MapViewModel()
    var annotations: AnnotationModel // Annotations'ı burada tanımlayın,


    
    typealias UIViewType = MKMapView
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        let annotation = annotations.annotation
        
        mapView.addAnnotation(annotation)
        
        return mapView
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
            // Check if shouldUpdate is true before performing updates
        if viewModel.shouldUpdate {
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                let region = MKCoordinateRegion(center: annotations.annotation.coordinate, span: span)
                uiView.setRegion(region, animated: true)
                
                uiView.isZoomEnabled = true
                uiView.isScrollEnabled = true
            }
        uiView.isZoomEnabled = true
        uiView.isScrollEnabled = true
    }
}


