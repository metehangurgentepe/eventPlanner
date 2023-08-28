//
//  CategoriesModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 18.07.2023.
//

import Foundation


struct CategoryModel:Identifiable{
    let id = UUID()
    let title: LocaleKeys.Category
    let image: IconItemString.Category
    
    static var Categories = [
        CategoryModel(title: .concert, image: .concert),
        CategoryModel(title: .party, image: .party),
        CategoryModel(title: .dinner, image: .dinner),
        CategoryModel(title: .sport, image: .sport),
        CategoryModel(title: .other, image: .other)
    ]
}
