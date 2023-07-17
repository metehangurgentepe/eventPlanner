//
//  MainTabView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 11.07.2023.
//

import SwiftUI

struct MainTabView: View {
    @State var size = UIScreen.main.bounds.height*0.1
    @State private var animate : Bool = false
    var body: some View {
        TabView{
            ForEach(HomeTabItem.tabItems){ item in
                item.page.tabItem {
                    TabIconLabel(model: item.model)
                        .animation(.spring(), value: animate)
                }
            }
        }
        .accentColor(.red)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

private struct TabIconLabel: View {
    let model : HomeTabModel
    let size = UIScreen.main.bounds.height*0.1
    var body: some View {
        VStack{
            Image(systemName: model.icon.rawValue)
                .frame(height: size)
            Text(model.title.rawValue.locale())
        }
    }
}
