//
//  MyEventsView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 19.07.2023.
//

import SwiftUI

struct MyEventsView: View {
    @StateObject var viewModel = EventPageViewModel()
    @State var text = ""
    
    var body: some View {
        ScrollView{
            VStack {
                HStack {
                    Text(LocaleKeys.Event.title.rawValue.locale())
                        .font(.system(.largeTitle,weight: .black))
                    Spacer()
                }
                .padding()
                
                if viewModel.upcomingEventList.first?.eventPhoto != nil{
                    ImageView()
                } else {
                    NavigationLink(destination: AddEventView(selectedOption: LocaleKeys.addEvent.select.rawValue, selectedIcon: IconItemString.Event.select.rawValue, isNavigatedToHomeView: false)) {
                        VStack{
                            ZStack{
                                Circle()
                                Image(systemName: IconItemString.Event.camera.rawValue)
                                    .imageScale(.large)
                                    .symbolRenderingMode(.monochrome)
                                    .foregroundColor(Color(.systemBackground))
                            }
                            Text(LocaleKeys.Event.create.rawValue.locale())
                                .font(.largeTitle)
                        }.foregroundColor(.black)
                            .frame(height: UIScreen.main.bounds.height * 0.2)
                    }
                }
                Spacer(minLength: 50)
                
                VStack {
                    HStack {
                        Text(LocaleKeys.Event.upcoming.rawValue.locale())
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.system(.title2, weight: .black))
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if viewModel.upcomingEventList.count == 0 && viewModel.upcomingPublicEvent.count == 0{
                        Text(LocaleKeys.Event.noEvent.rawValue.locale())
                            .font(.subheadline)
                            .padding(.all)
                    } else{
                        EventScrolldView()
                    }
                }.frame(maxHeight: UIScreen.main.bounds.height * 0.3)
                Spacer(minLength: 50)
                
                HStack {
                    Text(LocaleKeys.Event.request.rawValue.locale())
                        .font(.system(.title2, weight: .black))
                    Spacer()
                    NavigationLink(destination: RequestView()) {
                        Text(LocaleKeys.Event.view.rawValue.locale())
                    }
                }
                .padding(.horizontal)
                
                
                if viewModel.requestList.first != nil {
                    Group{
                        if let associatedEvent = viewModel.eventList.first(where: { $0.id == viewModel.requestList.first?.eventId }) {
                            RequestsView(event: associatedEvent)
                        }
                    }
                }
                else {
                    Text(LocaleKeys.Event.noRequest.rawValue.locale())
                        .font(.subheadline)
                        .padding(.top)
                }
                
            }.onAppear{
                viewModel.getUpcomingList()
                viewModel.getPublicUpcomingList()
            }
        }
        .navigationBarBackButtonHidden()
    }
    
}

struct MyEventsView_Previews: PreviewProvider {
    static var previews: some View {
        MyEventsView()
    }
}

struct EventScrolldView: View {
    @StateObject var viewModel = EventPageViewModel()
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(viewModel.upcomingEventList.count == 0 ? viewModel.upcomingPublicEvent : viewModel.upcomingEventList) { item in // Replace with your data model get
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.gray.opacity(0.2))
                        VStack {
                            AsyncImage(url:URL(string:item.eventPhoto )) { image in
                                image
                                    .resizable()
                                    .cornerRadius(12)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.1)
                                
                            } placeholder: {
                                Color.gray
                                    .frame(width:UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.1)
                            }
                            Spacer()
                            
                            Text(item.eventName)
                                .frame(maxWidth:UIScreen.main.bounds.width * 0.3)
                            Spacer()
                            
                            ZStack{
                                NavigationLink(destination: DetailEventView(eventId: item.id)) {
                                    Text(LocaleKeys.Event.viewDetails.rawValue.locale())
                                        .foregroundColor(.black)
                                    
                                }
                            }.background{
                                Capsule()
                                    .fill(.white)
                                    .frame(width:  UIScreen.main.bounds.width * 0.28, height: 20)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.black, lineWidth: 1) // Set the border color and width
                                    )
                            }
                            
                        }
                    }
                    .padding(.vertical)
                }
            }.onAppear{
                viewModel.getRequest()
                viewModel.getPublicUpcomingList()
            }
            .padding(.horizontal)
        }
    }
}

struct ImageView: View {
    @StateObject var viewModel = EventPageViewModel()
    var body: some View {
        VStack {
            AsyncImage(url:URL(string:viewModel.upcomingEventList.first!.eventPhoto )) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(height: UIScreen.main.bounds.height * 0.3)
            } placeholder: {
                Color.gray
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: UIScreen.main.bounds.width * 0.2, height: UIScreen.main.bounds.height * 0.15)
            }
            
            Text(viewModel.upcomingEventList.first!.eventName)
                .frame(minHeight:UIScreen.main.bounds.height * 0.04,maxHeight:UIScreen.main.bounds.height * 0.07)
            HStack {
                Text(viewModel.convertToDate(dateStr: viewModel.upcomingEventList.first!.eventStartTime.description)+",")
                Text(viewModel.convertToTime(timeStr: viewModel.upcomingEventList.first!.eventStartTime.description))
            }
        }
    }
}

struct RequestsView: View {
    @StateObject var viewModel = EventPageViewModel()
    @State var event : Event
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: event.eventPhoto)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .frame(maxWidth:UIScreen.main.bounds.width * 0.24,maxHeight: UIScreen.main.bounds.height * 0.2)
                
            } placeholder: {
                RoundedRectangle(cornerRadius:12)
                    .frame(maxWidth:UIScreen.main.bounds.width * 0.24,maxHeight: UIScreen.main.bounds.height * 0.1)
            }
            
            Spacer()
            VStack{
                Text(viewModel.requestList.first!.senderUser)
                    .font(.footnote)
                
                Text(viewModel.requestList.first!.eventName)
                    .fontWeight(.black)
                    .font(.subheadline)
                Text("\(viewModel.convertToDate(dateStr: viewModel.eventList.first?.eventStartTime ?? "")) \(viewModel.convertToTime(timeStr: viewModel.eventList.first?.eventStartTime ?? ""))")
            }
            Spacer()
            
            Button{
                viewModel.acceptRequest(requestId: viewModel.requestList.first!.id , eventId: viewModel.requestList.first!.eventId, sender: viewModel.requestList.first!.senderUser)
                removeRequest(withID: viewModel.requestList.first!.id) // İsteği kaldır
                
            } label:{
                Image(systemName: IconItemString.Event.tick.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width:UIScreen.main.bounds.width * 0.08)
            }
            
            Button{
                viewModel.rejectRequest(requestId: viewModel.requestList.first!.id)
            } label:{
                Image(systemName: IconItemString.Event.close.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width:UIScreen.main.bounds.width * 0.08)
            }
        }.padding(.horizontal)
    }
    func removeRequest(withID requestID: String) {
        // İlgili isteği listeden kaldır
        viewModel.requestList.removeAll { request in
            return request.id == requestID
        }
    }
}
