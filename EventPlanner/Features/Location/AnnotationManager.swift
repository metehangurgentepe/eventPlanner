//
//  AnnotationManager.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 14.07.2023.
//
import Foundation
import MapKit
@MainActor
class AnnotationStore: ObservableObject {
    @Published var annotation: MKPointAnnotation? // Use optional to store one annotation

    init() {
        annotation = nil // Initialize with no annotation
    }

    func setAnnotation(_ annotation: MKPointAnnotation) {
        self.annotation = annotation
    }
}
