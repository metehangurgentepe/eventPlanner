//
//  LocationManager.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 14.07.2023.
//

import Foundation
import MapKit


class LocationManager: NSObject, ObservableObject {
    @Published var location : CLLocation?
    @Published var region = MKCoordinateRegion()
    var locationReceived = false
    private let locationManager = CLLocationManager()
    private var locationUpdateTimer: Timer?
    @Published var locations: [CLLocation] = []

    
    override init(){
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    // Konum alımını başlatan fonksiyon
        func startUpdatingLocation() {
            locationManager.startUpdatingLocation()
            // Belirli bir süre sonra konum güncellemelerini durduracak bir zamanlayıcı başlatın
            locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { [weak self] timer in
                self?.stopUpdate()
            }
        }
    func stopUpdate(){
        print("stopped updating")
        locationManager.stopUpdatingLocation()
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
    }
}
extension LocationManager :CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {return}
        self.location = location
        self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    }
}
   
