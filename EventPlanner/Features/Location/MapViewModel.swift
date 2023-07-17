//
//  MapViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 14.07.2023.
//
/*
import Foundation
import CoreLocation
import MapKit

class MapViewModel : NSObject, ObservableObject,  CLLocationManagerDelegate{
    
    var locationManager : CLLocationManager?
    
    @Published var region = MKCoordinateRegion (center:
        CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054),
                                                      span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            checkLocationAuth()
        } else {
            print("show alert go turn location on")
        }
    }
    
    private func checkLocationAuth(){
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location restricted")
        case .denied:
            print("You have denied this app location permission. Go into your settings to change it")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        @unknown default:
            break
        }
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuth()
    }
}
*/
