//
//  SplashView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 20.08.2023.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var authVM: AuthManager
    @EnvironmentObject var eventVM : EventViewModel
    @State private var selectedEvent: Event? = nil
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var offsetY: CGFloat = 1000 // Başlangıçta metni ekranın dışında başlatın
    @State private var navigateToDetail = false
    @State private var navigateToMustLogin = false
    
    
    var body: some View {
        if isActive{
            if authVM.userSession != nil {
                            MainTabView()
                                .onOpenURL { url in
                                    if url.absoluteString.contains("event_id") {
                                        eventVM.getEventData(eventUrl: url.absoluteString) { event in
                                            if let event = event {
                                                selectedEvent = event
                                                navigateToDetail = true
                                            } else {
                                                // Handle error if event data couldn't be fetched
                                            }
                                        }
                                    }
                                }
                                .background(
                                    NavigationLink(
                                        destination: DetailEventView(eventId: selectedEvent?.id ?? "" ), // Provide a default if selectedEvent is nil
                                        isActive: $navigateToDetail,
                                        label: { EmptyView() }
                                    )
                                )
                        } else {
                            LoginView()
                                .onOpenURL { url in
                                    if url.absoluteString.contains("event_id") {
                                        eventVM.getEventData(eventUrl: url.absoluteString) { event in
                                            if let event = event {
                                                navigateToMustLogin = true
                                            } else {
                                                // Handle error if event data couldn't be fetched
                                            }
                                        }
                                    }
                                }.background(
                                    NavigationLink(destination: MustLoginView(), isActive: $navigateToMustLogin, label: {EmptyView()})
                                )
                        }
        } else{
            VStack{
                VStack{
                    Image("Eventier")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width * 0.4)
                    Text("Eventıer")
                        .font(.custom("TiltPrism-Regular", size: UIScreen.main.bounds.height * 0.1))
                        .foregroundColor(.black)
                        .offset(y: offsetY)
                        .scaleEffect(size)
                        .opacity(opacity)
                        .animation(
                            Animation.spring(response: 0.5, dampingFraction: 0.3, blendDuration: 0.5) // Bounce efekti için spring animasyonu kullanın
                        )
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear{
                    withAnimation(.easeIn(duration: 2)){
                        self.size = 0.9
                        self.opacity = 1.0
                        self.offsetY = 0
                    }
                }
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                    self.isActive = true
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}


