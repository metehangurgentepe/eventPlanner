//
//  HomeView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 6.07.2023.
//

import SwiftUI
import GoogleMobileAds


struct HomeView: View {
    @State private var events: [Event] = []
    @State private var error: Error?
    @ObservedObject  var eventVM = EventViewModel()
    //@EnvironmentObject var authVM : AuthViewModel
    @StateObject  var homeVM = HomeViewModel()
    @StateObject var savedVM = SavedEventViewModel()
   // @EnvironmentObject var locationManager : LocationManager
    @State var animate : Bool = false
    @State var text = ""
    @State var selectedCategory : String = ""
    @State var isSelected : Bool = false
    @State var isEmptyText : Bool = true
    @State var selectedTab = CategoryModel(title: LocaleKeys.Category.other, image: IconItemString.Category.other)
    
    var body: some View {
        NavigationView{
            ScrollView {
                VStack{
                    HStack{
                        Image(IconItemString.Home.logo.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 50)
                            .offset(x:-UIScreen.main.bounds.width * 0.033)
                        Spacer()
                        HStack{
                            NavigationLink(destination: AddEventView(isNavigatedToHomeView: true)) {
                                Image(systemName: IconItemString.Home.plus.rawValue)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.red)
                            }
                        }
                    }.padding(.horizontal)
                    
                    
                    HStack {
                        Image(systemName: IconItemString.Home.search.rawValue)
                            .foregroundColor(.black)
                        
                        TextField(LocaleKeys.Home.search.rawValue.locale(), text: $text)
                            .onChange(of: text) { newValue in
                                isEmptyText = text.isEmpty
                                homeVM.getPublicData(searchQuery: text, category: selectedCategory)
                        }
                        
                        isEmptyText ? Button{} label: {
                            Image(systemName: "")
                        }
                        : Button{
                            text = ""
                        } label: {
                            Image(systemName: IconItemString.Home.close.rawValue)
                        }
                        
                        
                        Image(systemName: IconItemString.Home.list.rawValue)
                    }.modifier(customViewModifier(roundedCornes: 6, startColor: .white, endColor: .white, textColor: .black))
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom)
                    
                    
                    HStack {
                        ForEach(CategoryModel.Categories, id: \.id) { item in
                            Button {
                                homeVM.selectedCategory = item.title.rawValue
                                homeVM.getPublicData(searchQuery: text, category: selectedCategory)
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
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(homeVM.selectedCategory == item.title.rawValue ? .white : .black) // Change the color based on the selected category
                                    }
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(10)
                                    Text(item.title.rawValue.locale())
                                        .font(.footnote)
                                        .bold()
                                        .foregroundColor(homeVM.selectedCategory == item.title.rawValue ? .black : .black) // Change the color based on the selected category
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716").frame(height:UIScreen.main.bounds.height * 0.08)
                    
                    VStack {
                        if homeVM.isLoading {
                            ProgressView()
                        } else{
                            if homeVM.publicEventList.count > 0{
                                ForEach(homeVM.publicEventList, id: \.id) { item in
                                    ListItemView(item: item)
                                }
                            } else{
                                NoItemView()
                            }
                        }
                    }
                }
            }.refreshable{
                homeVM.getSavedPost()
                homeVM.getPublicData(searchQuery: text, category: selectedCategory)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
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



struct ListItemView: View {
    @StateObject  var homeVM = HomeViewModel()
    let item : Event
    var body: some View {
        NavigationLink(destination: DetailEventView(eventId: item.id) ) {
            VStack {
                ZStack {
                    AsyncImage(url: URL(string:item.eventPhoto)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.25)
                        
                    } placeholder: {
                        Color.gray
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.3)
                            .cornerRadius(12)
                    }.padding(.horizontal)
                    
                    VStack{
                        HStack{
                            Spacer()
                            Button{
                                Task{
                                    homeVM.savePost(eventId: item.id)
                                }
                            } label:{
                                Group{
                                    if let savedPost = homeVM.savedPost {
                                        if savedPost.eventsId.contains(item.id) {
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
                        }
                        Spacer()
                    }.padding()
                }
                
                HStack {
                    Text(item.eventName)
                        .bold()
                        .foregroundColor(.black)
                        .font(.title2)
                    Spacer()
                }.padding(.horizontal)
                HStack {
                    Text(item.location)
                        .foregroundColor(.gray)
                    Spacer()
                }.padding(.horizontal)
                
                HStack{
                    Text(homeVM.convertToTime(timeStr: item.eventStartTime))
                    Text(homeVM.convertToDate(dateStr: item.eventStartTime))
                    
                    Spacer()
                    
                }.font(.footnote)
                    .bold()
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
            }.padding(.top)
        }
    }
}

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
