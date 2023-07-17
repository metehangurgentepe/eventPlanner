//
//  HomeView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 6.07.2023.
//

import SwiftUI


struct HomeView: View {
    @State private var events: [Event] = []
    @State private var error: Error?
    @ObservedObject  var eventVM = EventViewModel()
    @EnvironmentObject var authVM : AuthViewModel
    @State var animate : Bool = false
    init(){
        eventVM.getPublicData()
    }
    
    var body: some View {
        NavigationView {
            List(eventVM.list, id: \.id) { item in
                VStack(alignment: .leading) {
                    NavigationLink(destination: exampleDetailEventView(chosenEvent:item)) {
                        EmptyView()
                    }
                    Text(item.eventName)
                        .font(.title)
                        .bold()
                    
                    AsyncImage(url: URL(string:item.eventPhoto)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray
                            .frame(width: 100, height: 100)
                    }
                    Text(item.description)
                        .font(.subheadline)
                        .bold()
                        .padding(.bottom)
                    HStack {
                       
                        Text("Share")
                            .onTapGesture {
                                print("share")
                            }
                        
                        Spacer()
                        
                        Group {
                            if animate {
                                Image(systemName: "bookmark.fill")
                            } else {
                                Image(systemName: "bookmark")
                            }
                        }
                        .animation(.easeInOut(duration: 2),value: animate)
                        .onTapGesture {
                            withAnimation {
                                animate.toggle()
                            }
                            
                        }
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack{
                        Image(systemName: "network")
                        Text("Planner")
                            .font(.title2)
                            .foregroundColor(.black)
                            .bold()
                        Spacer()
                        NavigationLink(destination: AddEventView()) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.cyan)
                        }
                        Button{
                            authVM.signOut()
                            
                        } label: {
                            Image(systemName: "arrow.left")
                        }
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

