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
    
    static let tabItems: [HomeTabItem] = [
    HomeTabItem(page: AnyView( HomeView()), model: HomeTabModel(title: .home, icon: .home)),
    HomeTabItem(page: AnyView(SavedEventView()), model: HomeTabModel(title: .saved, icon: .saved)),
    HomeTabItem(page: AnyView(MyEventsView()), model: HomeTabModel(title: .event, icon: .event)),
    HomeTabItem(page: AnyView(ProfileView()), model: HomeTabModel(title: .account, icon: .account)) ]
}

struct HomeTabModel{
    let title : LocaleKeys.Tab
    let icon : IconItemString.TabView
}
