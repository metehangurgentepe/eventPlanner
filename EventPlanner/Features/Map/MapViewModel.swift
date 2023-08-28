//
//  MapViewModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 23.08.2023.
//

import Foundation
import SwiftUI


class MapViewModel: ObservableObject{
    
    @Published var shouldUpdate : Bool = true
    
   init(){
       Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                   self.shouldUpdate = false
        }
    }
}
