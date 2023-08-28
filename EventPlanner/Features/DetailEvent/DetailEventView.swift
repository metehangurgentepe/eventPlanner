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

struct DetailEventView: View {
    @State private var isLoading = true
    @State private var event: Event?
    @State private var error: Error?
    @EnvironmentObject var authVM : AuthManager
    @State var user : User?
    @State private var containsUser = false
    @StateObject var viewModel : DetailEventViewModel
    @State var isUserInEvent : Bool = false
    @State var intersitial : GADInterstitialAd?
    @AppStorage("adCounter") var adCounter = 0 // Burada @AppStorage ile adCounter'ı tanımlıyoruz.
    @GestureState private var dragOffset = CGSize.zero
    let eventId: String// Store the eventId as a property
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    
    init(eventId: String) {
        self.eventId = eventId
        self._viewModel =  StateObject(wrappedValue: DetailEventViewModel(eventId: eventId))
        //   removeAnnotation()
    }
    
    var body: some View {
        NavigationView{
            if viewModel.isLoading{
                ProgressView()
            } else{
                if let chosenEvent = viewModel.event {
                    EventDetailsView(viewModel: viewModel, chosenEvent: chosenEvent)
                        .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                            if(value.startLocation.x < 60 &&
                               value.translation.width > 100) {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }))
                    
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
struct DetailEventView_Previews: PreviewProvider {
    static var previews: some View {
        DetailEventView(eventId: "")
    }
}

struct EventDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var eventVM = EventViewModel()
    @StateObject var viewModel : DetailEventViewModel
    @State var chosenEvent: Event
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
                    Text(chosenEvent.location)
                        .font(.system(.callout, weight: .medium))
                    Text(chosenEvent.description)
                        .font(.system(.callout).width(.condensed))
                        .padding(.vertical)
                }
                .padding(.horizontal, 24)
                
                
                VStack(alignment: .leading, spacing: 15) {
                    Text(LocaleKeys.DetailEvent.highlight.rawValue.locale())
                        .kerning(2.0)
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .foregroundColor(.secondary)
                    
                    
                    Group{
                        EventPropertiesRow(imageName: IconItemString.DetailEvent.network.rawValue, text: chosenEvent.eventType)
                        
                        EventPropertiesRow(imageName: IconItemString.DetailEvent.calendar.rawValue, text: eventVM.convertToDate(dateStr:chosenEvent.eventStartTime))
                        
                        EventPropertiesRow(imageName: IconItemString.DetailEvent.clock.rawValue, text: eventVM.convertToTime(timeStr: chosenEvent.eventStartTime))
                        
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
                                }
                            }
                        }
                        
                        // if user see whatsapp group chat link when joined event
                        if viewModel.isContainsUser == true{
                            HStack{
                                EventPropertiesRow(imageName: "message", text: chosenEvent.groupChatLink)
                                Button(action: {
                                    viewModel.copyToClipboard(text: chosenEvent.groupChatLink)
                                }) {
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                        }
                        
                        // if user see when joined event, anyway user see user count
                        if viewModel.isContainsUser == true {
                            HStack{
                                EventPropertiesRow(imageName: IconItemString.DetailEvent.person.rawValue, text: String(chosenEvent.users.count))
                                NavigationLink(destination: AddUserEventView(eventId: chosenEvent.id)) {
                                    Text(LocaleKeys.DetailEvent.users.rawValue.locale())
                                }
                            }
                        } else {
                            if !viewModel.isEventPublic(eventId: chosenEvent.id) {
                                EventPropertiesRow(imageName: IconItemString.DetailEvent.person.rawValue, text: String(chosenEvent.users.count))
                            }
                        }
                    }
                    HStack{
                        EventPropertiesRow(imageName:IconItemString.DetailEvent.location.rawValue , text: chosenEvent.location)
                        
                        NavigationLink(destination:DetailMapView(annotations: AnnotationModel(annotation: MKPointAnnotation(__coordinate:CLLocationCoordinate2D(latitude: chosenEvent.latitude, longitude: chosenEvent.longitude))))) {
                            Text(LocaleKeys.DetailEvent.location.rawValue.locale())
                        }
                    }
                }
                .padding(.horizontal, 24)
                VStack(spacing: 14) {
                    if viewModel.isLoading{
                        ProgressView()
                    }
                    else{
                        if viewModel.isContainsUser == true{
                            EmptyView()
                        } else {
                            if viewModel.isEventPublic(eventId: chosenEvent.id){
                                EmptyView()
                            } else{
                                Button{
                                    viewModel.sendRequest(receiver: chosenEvent.eventLeadUser, eventId: chosenEvent.id, eventName: chosenEvent.eventName)
                                    viewModel.isRequestSended(eventId: chosenEvent.id, receiver: chosenEvent.eventLeadUser)
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
                        }
                    }
                }.onAppear{
                    viewModel.isUserInEvent(eventId: chosenEvent.id)
                    viewModel.isRequestSended(eventId: chosenEvent.id, receiver: chosenEvent.eventLeadUser)
                }
                .padding(.vertical, 28)
                Spacer()
            }
            
        }.alert(isPresented: $viewModel.showAlert, content: {
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
