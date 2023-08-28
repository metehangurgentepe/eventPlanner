//
//  DistanceForLocationViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 23.08.2023.
//

import Foundation
import Firebase
import FirebaseAuth


class DistanceForLocationViewModel: ObservableObject{
    @Published var distance : Double
    
    let db = Firestore.firestore()
    let userDefaults = UserDefaults.standard
    
    init(){
        if userDefaults.double(forKey: "Distance").isNaN{
            userDefaults.set(200, forKey: "Distance")
            distance = userDefaults.double(forKey: "Distance")
        } else{
            distance = userDefaults.double(forKey: "Distance")

        }
    }
}
