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
    @State private var path = NavigationPath()
    @Binding var showSignInView: Bool
    @State var showSignIn: Bool = false
    
    var body: some View {
        NavigationStack(path:$path){
            ScrollView{
                VStack {
                    HStack {
                        Text(LocaleKeys.Event.title.rawValue.locale())
                            .font(.system(.largeTitle,weight: .black))
                        Spacer()
                    }
                    .padding()
                    
                    if viewModel.upcomingEventList.first?.eventPhoto != nil{
                        ImageView(list: viewModel.upcomingEventList, viewModel: EventPageViewModel())
                    } else {
                        Button {
                            if viewModel.isUserLoggedIn {
                                path.append(5)
                            } else {
                                viewModel.showAlert = true
                            }
                        } label: {
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
                        .alert(isPresented: $viewModel.showAlert, content: {
                            Alert(title: Text(LocaleKeys.Home.loginMessage.rawValue.locale()), primaryButton: .default(Text(LocaleKeys.Profile.noButton.rawValue.locale())) {
                                viewModel.showAlert = false
                            }, secondaryButton: .default(Text(LocaleKeys.Profile.yesButton.rawValue.locale())) {
                                showSignIn = true
                                showSignInView = true
                            })
                        })
                        
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
                            EventScrolldView(upcomingEventList: viewModel.upcomingEventList, upcomingPublicEvent: viewModel.upcomingPublicEvent, path: $path)
                                .onAppear{
                                    Task{
                                        try await viewModel.getUpcomingList()
                                        try await viewModel.getPublicUpcomingList()
                                    }
                                }
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
                    
                    
                    if let request = viewModel.requestList.first {
                        Group{
                            if let associatedEvent = viewModel.eventList {
                                HStack {
                                    AsyncImage(url: URL(string: associatedEvent.eventPhoto)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(12)
                                            .frame(maxWidth: UIScreen.main.bounds.width * 0.2, maxHeight: UIScreen.main.bounds.height * 0.15)
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 12)
                                            .frame(maxWidth: UIScreen.main.bounds.width * 0.2, maxHeight: UIScreen.main.bounds.height * 0.1)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Text(request.senderUser)
                                            .font(.footnote)
                                        
                                        Text(request.eventName)
                                            .fontWeight(.black)
                                            .font(.subheadline)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        Task{
                                            try await viewModel.acceptRequest()
                                            try await viewModel.getRequest()
                                        }
                                    } label: {
                                        Image(systemName: IconItemString.Event.tick.rawValue)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: UIScreen.main.bounds.width * 0.08)
                                    }
                                    
                                    Button {
                                        Task{
                                            try await viewModel.rejectRequest()
                                            try await viewModel.getRequest()
                                        }
                                    } label: {
                                        Image(systemName: IconItemString.Event.close.rawValue)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: UIScreen.main.bounds.width * 0.08)
                                    }
                                }.padding(.horizontal)


                            }
                        }
                        .onAppear{
                            Task{
                                try await viewModel.convertEvent(request:request)
                            }
                        }
                    }
                    else {
                        Text(LocaleKeys.Event.noRequest.rawValue.locale())
                            .font(.subheadline)
                            .padding(.top)
                    }
                }
            }
            .navigationDestination(for: Int.self){ number in
                AddEventView(path: $path, testInt: number)
            }
            .navigationDestination(for: AddEventData.self, destination: { values in
                AddEvent2View(eventName: values.name, eventType: values.selectedOption, description: values.desc, path: $path)
            })
            .onAppear{
                Task{
                    try await viewModel.fetchUser()
                    try await viewModel.getUpcomingList()
                    try await viewModel.getPublicUpcomingList()
                    try await viewModel.getRequest()
                    if let request = viewModel.requestList.first{
                        try await viewModel.convertEvent(request: request)
                    }
                }
            }
        }
        .background(
            NavigationLink(
                destination: LoginView(showSignInView: $showSignInView),
                isActive: $showSignIn,
                label: {
                    EmptyView()
                })
        )
        .navigationBarBackButtonHidden()
            .navigationViewStyle(StackNavigationViewStyle())
    }
    
}

struct MyEventsView_Previews: PreviewProvider {
    static var previews: some View {
        MyEventsView(showSignInView: .constant(false))
    }
}

struct EventScrolldView: View {
    @StateObject var viewModel = EventPageViewModel()
    var upcomingEventList: [EventDatabase]
    var upcomingPublicEvent: [EventDatabase]
    @Binding var path : NavigationPath
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(upcomingEventList.count == 0 ? upcomingPublicEvent : upcomingEventList) { item in // Replace with your data model get
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
                                NavigationLink(value: item.id) {
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
                            }.navigationDestination(for: String.self) { text in
                                DetailEventView(eventId:text,path:$path)
                            }
                            
                        }
                    }
                    .padding(.vertical)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ImageView: View {
    var list: [EventDatabase]
    var viewModel: EventPageViewModel
    var body: some View {
        VStack {
            AsyncImage(url:URL(string:list.first!.eventPhoto )) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.4, maxHeight: UIScreen.main.bounds.height * 0.25)
            } placeholder: {
                Color.gray
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: UIScreen.main.bounds.width * 0.2, height: UIScreen.main.bounds.height * 0.15)
            }
            
            Text(list.first!.eventName)
                .frame(minHeight:UIScreen.main.bounds.height * 0.04,maxHeight:UIScreen.main.bounds.height * 0.07)
            HStack {
                Text(viewModel.convertToDate(dateStr: list.first!.eventStartTime.description)+",")
                Text(viewModel.convertToTime(timeStr: list.first!.eventStartTime.description))
            }
        }
    }
}

/*struct RequestsView: View {
    var request : Request
    var event : EventDatabase
    // var viewModel: EventPageViewModel
    
    var body: some View {
            }
    func removeRequest(withID requestID: String) {
        // İlgili isteği listeden kaldır
        /*  viewModel.requestList.removeAll { request in
         return request.id == requestID
         } */
    }
} */
