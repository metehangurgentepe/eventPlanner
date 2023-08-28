//
//  MainTabView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 11.07.2023.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var eventVM = EventViewModel()
    @State var size = UIScreen.main.bounds.height * 0.1
    @State private var animate : Bool = false
    @State private var isNetworkReachable = true // Create a state variable
    @State private var isNetworkErrorPresented = false
    let networkReachability = NetworkReachability()
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
        .alert(isPresented: $isNetworkErrorPresented) {
            Alert(
                title: Text("Network Connection Error"),
                message: Text("There is a problem with the network."),
                dismissButton: .default(Text("Check Network Connection")){
                    if !networkReachability.reachable {
                        isNetworkErrorPresented = true
                    }
                }
            )
        }
        
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

private struct TabIconLabel: View {
    let model : HomeTabModel
    var body: some View {
        VStack{
            Image(model.icon.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
            Text(model.title.rawValue.locale())
        }
    }
}
