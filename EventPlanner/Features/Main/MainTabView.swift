//
//  MainTabView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 11.07.2023.
//

import SwiftUI

struct MainTabView: View {
    //@StateObject var eventVM = EventViewModel()
    @State var size = UIScreen.main.bounds.height * 0.1
    @State private var animate : Bool = false
    @State private var isNetworkReachable = true // Create a state variable
    @State private var isNetworkErrorPresented = false
    @Binding var showSignInView: Bool
    //@State private var showSignInView = true // or false, depending on your initial state
    var tabItems: [HomeTabItem]

    
    init(showSignInView: Binding<Bool>) {
           self._showSignInView = showSignInView
           self.tabItems = [
               HomeTabItem(page: AnyView(HomeView(showSignInView: showSignInView)), model: HomeTabModel(title: .home, icon: .home)),
               HomeTabItem(page: AnyView(SavedEventView()), model: HomeTabModel(title: .saved, icon: .saved)),
               HomeTabItem(page: AnyView(MyEventsView(showSignInView: showSignInView)), model: HomeTabModel(title: .event, icon: .event)),
               HomeTabItem(page: AnyView(ProfileView(showSignInView: showSignInView)), model: HomeTabModel(title: .account, icon: .account))
           ]
       }
    
    var body: some View {
        TabView{
            ForEach(tabItems){ item in
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
        MainTabView( showSignInView: .constant(false))
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
