//
//  DetailEventView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 9.07.2023.
//

import SwiftUI
import FirebaseAuth

struct DetailEventView: View {
    @ObservedObject var eventVM = EventViewModel()
    @State private var isLoading = true
    @State private var event: Event?
    @State private var error: Error?
    @EnvironmentObject var authVM : AuthViewModel
    @State var user : User?
    @State private var containsUser = false
    
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter
    }()
    
    var chosenEvent : Event
    
    var body: some View {
        
        let date = dateFormatter.date(from: chosenEvent.eventStartTime)
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!)
        
        VStack{
            AsyncImage(url: URL(string:chosenEvent.eventPhoto)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
            } placeholder: {
                Color.gray
                    .frame(width: 100, height: 100)
            }
            
            
            Text("Description")
                .fontWeight(.medium)
                .padding(.vertical, 8)
            Text(chosenEvent.description)
                .lineSpacing(8.0)
                .opacity(0.6)
            
            
            
            Group{
                HStack (alignment: .top) {
                    VStack (alignment: .leading) {
                        Text("Size")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                        Text("Type: "+chosenEvent.eventType)
                            .opacity(0.6)
                        Text("Date: \(dateComponents.year ?? 0)-\(dateComponents.month ?? 0)-\(dateComponents.day ?? 0)")
                            .opacity(0.6)
                        Text("Time: \(dateComponents.hour ?? 0):\(dateComponents.minute ?? 0):\(dateComponents.second ?? 0)")
                            .opacity(0.6)
                        Text("Price: \(String(chosenEvent.price))tl")
                            .opacity(0.6)
                        Text("Number of people: \(chosenEvent.users.count)")
                            .opacity(0.6)
                    }
                    
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    VStack (alignment: .leading) {
                        Text("Planned by")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                        Text("\(chosenEvent.eventLeadUser)")
                            .opacity(0.6)
                        Text("\(chosenEvent.phoneNumber)")
                            .opacity(0.6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical)
            }.padding(.leading)
            
            
            HStack{
                Text("Location: \(chosenEvent.location)")
                Spacer()
                Button{
                    
                } label: {
                    Text("Go to location")
                }
            }
            .padding(.horizontal)
            
            //MapView(
            
            if containsUser {
                // User is in the array, do not show the button
                EmptyView()
            } else {
                Button(action: {}) {
                    Text("Join Event")
                }
                .buttonStyle(.bordered)
                .foregroundColor(Color(.black))
            }
            Spacer()
            
        }
        .onAppear(perform:setup)
        .navigationTitle("\(chosenEvent.eventName)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            
            Button{
                
                
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            
        }
    }
    func setup() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        containsUser = chosenEvent.users.contains(uid)
    }
    
}


