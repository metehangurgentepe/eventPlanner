//
//  exampleDetailEventView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 16.07.2023.
//

import SwiftUI
import CoreLocation
import GoogleMobileAds
import MapKit
import Firebase

struct DetailEventView: View {
    @State private var isLoading = true
    @State private var event: Event?
    @State private var error: Error?
    @EnvironmentObject var authVM : AuthManager
    @State var user : UserModel?
    @State private var containsUser = false
    @StateObject var viewModel = DetailEventViewModel()
    @State var isUserInEvent : Bool = false
    @State var intersitial : GADInterstitialAd?
    @AppStorage("adCounter") var adCounter = 0 // Burada @AppStorage ile adCounter'ı tanımlıyoruz.
    @GestureState private var dragOffset = CGSize.zero
    let eventId: String// Store the eventId as a property
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var path : NavigationPath
    
    
    var body: some View {
        VStack{
            if viewModel.isLoading{
                ProgressView()
            } else{
                if let chosenEvent = viewModel.event {
                    EventDetailsView(viewModel: viewModel, chosenEvent: chosenEvent, path: $path)
                        .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                            if(value.startLocation.x < 60 &&
                               value.translation.width > 100) {
                                path.removeLast()
                             //   self.presentationMode.wrappedValue.dismiss()
                            }
                        }))
                }
            }
        }.onAppear{
            Task{
                try await viewModel.getEventDetail(eventId: eventId)
                try await viewModel.isUserInEvent(eventId: eventId)
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct EventDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = DetailEventViewModel()
    @State private var isExpanded = false
    @State var chosenEvent: EventDatabase
    @Binding var path : NavigationPath
    var body: some View {
            ScrollView {
                VStack {
                    ZStack(alignment: .top) {
                        AsyncImage(url: URL(string:chosenEvent.eventPhoto)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaledToFit()
                        } placeholder: {
                            Color.gray
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.4)
                        }
                        
                        HStack{
                            Button {
                                /*  adCounter += 1
                                 print(adCounter)
                                 if adCounter % 3 == 1 {
                                 if  intersitial != nil {
                                 intersitial!.present(fromRootViewController: (UIApplication.shared.windows.first?.rootViewController)!)
                                 }
                                 } */
                                //  path.removeLast()
                                self.presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: IconItemString.DetailEvent.backButton.rawValue)
                                    .font(.title3)
                                    .padding(11)
                                    .background {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                    }
                                    .foregroundStyle(.red)
                            }
                            Spacer()
                            ShareLink(item: chosenEvent.eventUrl){
                                Image(systemName: "square.and.arrow.up")
                                    .scaleEffect(1)
                                    .font(.title3)
                                    .padding(10)
                                    .background {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                    }
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }.frame(height: UIScreen.main.bounds.height * 0.4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(chosenEvent.eventName)
                                .font(.system(size: 29, weight: .semibold, design: .default))
                            Spacer()
                        }
                        Text(chosenEvent.locationName)
                            .font(.system(.callout, weight: .medium))
                        
                        VStack {
                            if viewModel.countOfDesc(text: chosenEvent.description) > 100{
                                Text(chosenEvent.description)
                                    .font(.system(.callout).width(.condensed))
                                    .lineLimit(isExpanded ? nil : 3)
                                    .padding(.vertical)
                                
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        withAnimation {
                                            isExpanded.toggle()
                                        }
                                    }) {
                                        Text(isExpanded ? LocaleKeys.DetailEvent.close.rawValue.locale() : LocaleKeys.DetailEvent.readMore.rawValue.locale())
                                            .font(.system(.callout))
                                            .foregroundColor(.red)
                                    }
                                }
                            } else {
                                Text(chosenEvent.description)
                                    .font(.system(.callout).width(.condensed))
                                //  .lineLimit(isExpanded ? nil : 3)
                                    .padding(.vertical)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text(LocaleKeys.DetailEvent.highlight.rawValue.locale())
                            .kerning(2.0)
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(.secondary)
                        
                        
                        Group{
                            EventPropertiesRow(imageName: IconItemString.DetailEvent.network.rawValue, text: chosenEvent.eventType)
                            
                            EventPropertiesRow(imageName: IconItemString.DetailEvent.calendar.rawValue, text: viewModel.convertToDate(dateStr:chosenEvent.eventStartTime))
                            
                            EventPropertiesRow(imageName: IconItemString.DetailEvent.clock.rawValue, text: viewModel.convertToTime(timeStr: chosenEvent.eventStartTime))
                            
                            EventPropertiesRow(imageName: IconItemString.DetailEvent.dollar.rawValue, text: String(chosenEvent.price))
                            
                            EventPropertiesRow(imageName: IconItemString.DetailEvent.privateIcon.rawValue, text: chosenEvent.publicEvent ? LocaleKeys.DetailEvent.publicStr.rawValue : LocaleKeys.DetailEvent.privateStr.rawValue)
                            
                            
                            if viewModel.isContainsUser == true{
                                HStack{
                                    EventPropertiesRow(imageName: IconItemString.DetailEvent.phone.rawValue, text: chosenEvent.phoneNumber)
                                    Button(action: {
                                        let telephone = "tel://"
                                        let formattedString = telephone + chosenEvent.phoneNumber
                                        guard let url = URL(string: formattedString) else { return }
                                        UIApplication.shared.open(url)
                                    }) {
                                        Text(LocaleKeys.DetailEvent.call.rawValue.locale())
                                            .foregroundColor(.red)
                                    }
                                }
                                HStack{
                                    EventPropertiesRow(imageName: "message", text: chosenEvent.groupChatLink)
                                    Button(action: {
                                        viewModel.copyToClipboard(text: chosenEvent.groupChatLink)
                                    }) {
                                        Image(systemName: "doc.on.doc")
                                            .foregroundColor(.red)
                                    }
                                }
                                HStack{
                                    EventPropertiesRow(imageName: IconItemString.DetailEvent.person.rawValue, text: String(chosenEvent.users.count))
                                    NavigationLink(destination: AddUserEventView(eventId: chosenEvent.id)) {
                                        Text(LocaleKeys.DetailEvent.users.rawValue.locale())
                                            .foregroundColor(.red)
                                    }
                                }
                                
                            } else{
                                if !viewModel.publicEvent {
                                    EventPropertiesRow(imageName: IconItemString.DetailEvent.person.rawValue, text: String(chosenEvent.users.count))
                                }
                            }
                        }
                        HStack{
                            EventPropertiesRow(imageName:IconItemString.DetailEvent.location.rawValue , text: chosenEvent.locationName)
                            Button {
                                path.append(AnnotationModel(annotation: MKPointAnnotation(__coordinate: CLLocationCoordinate2DMake(chosenEvent.location.latitude, chosenEvent.location.longitude))))
                            } label: {
                                Text(LocaleKeys.DetailEvent.location.rawValue.locale())
                                    .foregroundColor(.red)

                            }
                            
                            /* NavigationLink(destination:DetailMapView(annotations: AnnotationModel(annotation: MKPointAnnotation(__coordinate:CLLocationCoordinate2D(latitude: chosenEvent.location.latitude, longitude: chosenEvent.location.longitude))))) {
                             Text(LocaleKeys.DetailEvent.location.rawValue.locale())
                             } */
                        }.navigationDestination(for: AnnotationModel.self){ annotation in
                            DetailMapView(annotations: annotation)
                        }
                    }
                    .padding(.horizontal, 24)
                    VStack(spacing: 14) {
                        if viewModel.isContainsUser || chosenEvent.publicEvent{
                            EmptyView()
                        } else {
                            Button{
                                Task{
                                    try await viewModel.sendRequest(receiver: chosenEvent.eventLeadUser, eventId: chosenEvent.id, eventName: chosenEvent.eventName)
                                    try await viewModel.isRequestSended(eventId: chosenEvent.id, receiver: chosenEvent.eventLeadUser)
                                    AnalyticsManager.shared.logEvent(name: "DetailEventView_SendRequestButtonClicked")
                                }
                            } label: {
                                Text(viewModel.requestSended ? LocaleKeys.DetailEvent.requestSended.rawValue.locale() : LocaleKeys.DetailEvent.reserve.rawValue.locale() )
                                    .font(.system(.title3, weight: .medium))
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(viewModel.requestSended ? .orange.opacity(0.3) : .orange)
                                    .foregroundColor(.white)
                                    .mask {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    }
                                
                            }.disabled(viewModel.requestSended)
                        }
                    }.onAppear{
                        Task{
                            try await viewModel.isUserInEvent(eventId: chosenEvent.id)
                            try await viewModel.isRequestSended(eventId: chosenEvent.id, receiver: chosenEvent.eventLeadUser)
                        }
                    }
                    .padding(.vertical, 28)
                    Spacer()
                }
                
            }
            .toolbar(.hidden)
            .alert(isPresented: $viewModel.showAlert, content: {
                Alert(
                    title: Text(LocaleKeys.addEvent.errorTitle.rawValue.locale()),
                    message: Text(viewModel.errorMessage.locale()),
                    dismissButton: .default(Text(LocaleKeys.addEvent.okButton.rawValue.locale())) {
                        viewModel.showAlert = false
                    }
                )
            })
    }
}
