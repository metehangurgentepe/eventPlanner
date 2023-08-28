//
//  MapUIView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 2.08.2023.
//

import SwiftUI
import CoreLocation
import MapKit

struct MapUIView: View {
    var latitude: Double
    var longitude: Double
    @StateObject var viewModel = MapViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
            VStack {
                Text(LocaleKeys.Map.tap.rawValue.locale())
                AddMapView(editAnnotation: false, annotations: AnnotationModel(annotation: MKPointAnnotation(__coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))))
            }
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.title)
            })
            .navigationBarBackButtonHidden()
    }
}


struct MapUIView_Previews: PreviewProvider {
    static var previews: some View {
        MapUIView(latitude: 27.32, longitude: 27.31)
    }
}
