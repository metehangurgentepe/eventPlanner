//
//  HomeView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 6.07.2023.
//

import SwiftUI
import GoogleMobileAds


struct HomeView: View {
    @StateObject private var homeVM = HomeViewModel()
    @State var isEmptyText: Bool = true
    @State var selectedTab = CategoryModel(title: LocaleKeys.Category.other, image: IconItemString.Category.other)
    @State var path = NavigationPath()
    @State var isPresentedAddEvent : Bool = false
    @State var number : Int = 5
    @State var isClicked : Bool = false
    @State var isFirstTime: Bool = true
    @Binding var showSignInView: Bool
    @State var showSignIn : Bool = false
    @State var showAlert : Bool = false
    
    let Categories = [
        CategoryModel(title: .concert, image: .concert),
        CategoryModel(title: .party, image: .party),
        CategoryModel(title: .dinner, image: .dinner),
        CategoryModel(title: .sport, image: .sport),
        CategoryModel(title: .other, image: .other)
    ]
    
    var body: some View {
        NavigationStack(path: $path){
            ScrollView {
                VStack {
                    HStack {
                        Image(IconItemString.Home.logo.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: UIScreen.main.bounds.width * 0.1)
                            .offset(x: -UIScreen.main.bounds.width * 0.033)
                        
                        Spacer()
                        
                        Button{
                            print("plus button")
                            print(homeVM.isUserLoggedIn)

                            if homeVM.isUserLoggedIn {
                                path.append(5)
                                withAnimation {
                                    isClicked.toggle()
                                }
                            } else{
                                homeVM.showAlert = true
                            }
                        } label: {
                            HStack {
                                    Image(systemName: IconItemString.Home.plus.rawValue)
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width * 0.07, height: UIScreen.main.bounds.width * 0.07)
                                        .foregroundColor(.red)
                                        .animation(.spring(), value: isClicked)
                            }
                        }
                        
                        
                    }
                    .padding(.horizontal)
                    .navigationDestination(for: AnnotationModel.self){ annotation in
                        DetailMapView(annotations: annotation)
                    }
                    
                    .navigationDestination(for: Int.self){ number in
                        AddEventView(path: $path, testInt: number)
                    }
                    .navigationDestination(for: AddEventData.self){ values in
                        AddEvent2View(eventName: values.name, eventType:values.selectedOption , description: values.desc, path: $path)
                    }
                    
                    
                    HStack {
                        Image(systemName: IconItemString.Home.search.rawValue)
                            .foregroundColor(.black)
                        
                        TextField(LocaleKeys.Home.search.rawValue.locale(), text: $homeVM.text)
                            .onChange(of: homeVM.text) { newValue in
                                isEmptyText = homeVM.text.isEmpty
                                Task {
                                    try await homeVM.filterFunc()
                                }
                            }
                        
                        isEmptyText ? Button {} label: {
                            Image(systemName: "")
                        } : Button {
                            homeVM.text = ""
                        } label: {
                            Image(systemName: IconItemString.Home.close.rawValue)
                        }
                        
                        Image(systemName: IconItemString.Home.list.rawValue)
                    }
                    .modifier(customViewModifier(roundedCornes: 6, startColor: .white, endColor: .white, textColor: .black))
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom)
                    
                    HStack {
                        ForEach(Categories, id: \.id) { item in
                            Button {
                                Task {
                                    homeVM.selectedCategory = item.title.rawValue // Seçilen kategoriyi güncellemek isterseniz bu satırı kullanabilirsiniz.
                                    try await homeVM.filterFunc()
                                }
                            } label: {
                                VStack {
                                    ZStack {
                                        if homeVM.selectedCategory == item.title.rawValue {
                                            Rectangle()
                                                .fill(Color.black.opacity(0.9))
                                               
                                        } else {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.1))
                                                
                                        }
                                        
                                        Image(item.image.rawValue)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: UIScreen.main.bounds.width * 0.06, height: UIScreen.main.bounds.width * 0.06)
                                            .foregroundColor(homeVM.selectedCategory == item.title.rawValue ? .white : .black)
                                    }
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(10)
                                    Text(item.title.rawValue.locale())
                                        .font(.footnote)
                                        .bold()
                                        .foregroundColor(homeVM.selectedCategory == item.title.rawValue ? .black : .black)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack {
                        if homeVM.isLoading {
                            ProgressView()
                        } else {
                            if homeVM.events.count > 0 {
                                // home view cell
                                VStack {
                                    ForEach(homeVM.events) { item in
                                        NavigationLink(value: item.id) {
                                            HomeViewCell(homeVM: homeVM, showSignInView:$showSignInView,showSignIn: $showSignIn, event:item)

                                        }
                                        .alert(isPresented: $homeVM.showAlert, content: {
                                            Alert(title: Text(LocaleKeys.Home.saveEventMessage.rawValue.locale()), primaryButton: .default(Text(LocaleKeys.Profile.noButton.rawValue.locale())) {
                                                homeVM.showAlert = false
                                            }, secondaryButton: .default(Text(LocaleKeys.Profile.yesButton.rawValue.locale())) {
                                                showSignIn = true
                                                showSignInView = true
                                            })
                                        })
                                           /* if item == homeVM.events.last{
                                                ProgressView()
                                                    .onAppear{
                                                        Task{
                                                          // try await homeVM.getAllPublicEvents()
                                                            print("PROGREES VİEW APPEARED")
                                                        }
                                                    }
                                            } */
                                    }
                                }.navigationDestination(for: String.self) { textValue in
                                    DetailEventView(eventId:textValue, path: $path)
                                }
                                
                                
                               /* .navigationDestination(isPresented: $isPresentedAddEvent) {
                                    AddEventView(path: $path)
                                }*/
                                
                            } else if isFirstTime {
                                NoItemView()
                            }
                            
                        }
                    }
                }
                .alert(isPresented: $homeVM.showAlert, content: {
                    Alert(title: Text(LocaleKeys.Home.loginMessage.rawValue.locale()), primaryButton: .default(Text(LocaleKeys.Profile.noButton.rawValue.locale())) {
                        homeVM.showAlert = false
                    }, secondaryButton: .default(Text(LocaleKeys.Profile.yesButton.rawValue.locale())) {
                        showSignIn = true
                        showSignInView = true
                    })
                })
            }.toolbar(.hidden)
            .onAppear {
                Task {
                    try await homeVM.fetchUser()
                    try await homeVM.filterFunc()
                }
            }
            .refreshable {
                Task {
                    try await homeVM.filterFunc()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden()
        .toolbar(.hidden)
        .background(
            NavigationLink(
                destination: LoginView(showSignInView: $showSignInView),
                isActive: $showSignIn,
                label: {
                    EmptyView()
                })
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView( showSignInView: .constant(true))
    }
}

/*struct AdBannerView: UIViewRepresentable {
 let adUnitID: String
 
 func makeUIView(context: Context) -> GADBannerView {
 let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: UIScreen.main.bounds.width, height: 50))) // Set your desired banner ad size
 bannerView.adUnitID = adUnitID
 bannerView.rootViewController = UIApplication.shared.windows.first?.rootViewController
 bannerView.load(GADRequest())
 return bannerView
 }
 
 func updateUIView(_ uiView: GADBannerView, context: Context) {}
 } */



/* struct ListItemView: View {
 let item : Event
 var body: some View {
 
 }
 } */

struct NoItemView: View {
    var body: some View {
        VStack(spacing:UIScreen.main.bounds.height * 0.1){
            Spacer()
            VStack{
                Text(LocaleKeys.Home.noEvent.rawValue.locale())
                    .font(.title3)
                    .padding(.top)
                Text(LocaleKeys.Home.refresh.rawValue.locale())
                    .font(.caption)
            }
            NavigationLink(destination: DistanceForLocationView()){
                ZStack{
                    Capsule()
                    Text(LocaleKeys.Home.button.rawValue.locale())
                        .font(.headline)
                        .foregroundColor(.black)
                }.frame(width:UIScreen.main.bounds.width * 0.85,height:UIScreen.main.bounds.height * 0.06)
            }
        }
    }
}

struct HomeViewCell: View {
    @StateObject var homeVM : HomeViewModel
    @Binding var showSignInView: Bool
    @Binding var showSignIn : Bool
    let event : EventDatabase
    var body: some View {
        VStack {
            ZStack {
                AsyncImage(url: URL(string: event.eventPhoto)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.25)
                } placeholder: {
                    Color.gray
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.3)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            Task {
                                print("kullanıcı içeride")
                                print(homeVM.isUserLoggedIn)
                                try await homeVM.fetchUser()
                                if homeVM.isUserLoggedIn {
                                    try await homeVM.saveEvent(eventId: event.id)
                                    try await homeVM.getSavedEvents()
                                } else {
                                    print("buraya giriyor")
                                    homeVM.showAlert = true
                                }
                            }
                        } label: {
                            Group {
                                if let savedPost = homeVM.savedEvents {
                                    if savedPost.eventsId.contains(event.id) {
                                        Image(systemName: IconItemString.Home.liked.rawValue)
                                    } else {
                                        Image(systemName: IconItemString.Home.unliked.rawValue)
                                    }
                                } else {
                                    ProgressView()
                                }
                            }
                            .symbolRenderingMode(.monochrome)
                            .padding()
                            .imageScale(.large)
                            .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                        }
                        .alert(isPresented: $homeVM.showAlert, content: {
                            Alert(title: Text(LocaleKeys.Home.loginMessage.rawValue.locale()), primaryButton: .default(Text(LocaleKeys.Profile.noButton.rawValue.locale())) {
                                homeVM.showAlert = false
                            }, secondaryButton: .default(Text(LocaleKeys.Profile.yesButton.rawValue.locale())) {
                                showSignIn = true
                                showSignInView = true
                            })
                        })
                    }
                    Spacer()
                }
                .padding()
            }
            
            HStack {
                Text(event.eventName)
                    .bold()
                    .foregroundColor(.black)
                    .font(.title2)
                Spacer()
            }
            .padding(.horizontal)
            HStack {
                Text(event.locationName)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal)
            
            HStack {
                Text(homeVM.convertToTime(timeStr: event.eventStartTime))
                Text(homeVM.convertToDate(dateStr: event.eventStartTime))
                
                Spacer()
            }
            .font(.footnote)
            .bold()
            .foregroundColor(.gray)
            .padding(.horizontal)
        }.onAppear{
            Task{
                try await homeVM.fetchUser()
                try await homeVM.getSavedEvents()
            }
        }
        .padding(.top)
    }
}
