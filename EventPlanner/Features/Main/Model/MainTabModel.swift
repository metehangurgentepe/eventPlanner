//
//  MainTabModel.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 11.07.2023.
//

import Foundation
import SwiftUI

struct HomeTabItem : Identifiable{
    let id = UUID()
    let page : AnyView
    let model : HomeTabModel
   // let showSignInView: Binding<Bool>
    
   
}

struct HomeTabModel{
    let title : LocaleKeys.Tab
    let icon : IconItemString.TabView
}
