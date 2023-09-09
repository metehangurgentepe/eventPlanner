//
//  AnnotationModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 14.07.2023.
//

import Foundation
import MapKit

struct AnnotationModel: Identifiable, Hashable {
    let id = UUID()
    let annotation: MKPointAnnotation
}
