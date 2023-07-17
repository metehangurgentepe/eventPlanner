//
//  AddEventModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 13.07.2023.
//

import Foundation


class AlertModel: ObservableObject {
    @Published var success: Bool
    @Published var message: String
    @Published var title: String
    
    init(success: Bool, message: String, title: String) {
        self.success = success
        self.message = message
        self.title = title
    }
}
