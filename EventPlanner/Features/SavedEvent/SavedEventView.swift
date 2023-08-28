//
//  SavedEventView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 24.07.2023.
//

import SwiftUI

struct SavedEventView: View {
    @StateObject var viewModel = SavedEventViewModel()
    
    var body: some View {
        NavigationView{
            ScrollView{
            VStack{
                if viewModel.events != [] {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(viewModel.events) { event in // Replace with your data model here
                            EventView(event: event)
                        }
                    }
                }else{
                    VStack{
                        Text(LocaleKeys.Saved.create.rawValue.locale())
                        Text(LocaleKeys.Saved.subtitle.rawValue.locale())
                            .foregroundColor(.gray)
                        
                    }.padding(.top)
                }
                Spacer()
            }
            .padding(.horizontal)
            .navigationBarTitle(LocaleKeys.Saved.title.rawValue.locale(), displayMode: .large)
            }
            .onAppear{
                Task{
                    if viewModel.events.count !=  viewModel.lengthofEvents(){
                        await viewModel.getSavedEvents()
                    }
                }
            }
        }
    }
}

struct SavedEventView_Previews: PreviewProvider {
    static var previews: some View {
        SavedEventView()
    }
}

struct EventView: View {
    let event: Event
    var body: some View {
        NavigationLink(destination: DetailEventView(eventId: event.id)) {
            ZStack {
                VStack {
                    ZStack{
                        AsyncImage(url: URL(string: event.eventPhoto)) { image in
                            image
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .shadow(color: Color(.tertiaryLabel).opacity(0.5), radius: 8, x: 0, y: 4)
                                .mask { RoundedRectangle(cornerRadius: 14, style: .continuous)}
                                .cornerRadius(12)
                                .frame(width:UIScreen.main.bounds.width * 0.3,height: UIScreen.main.bounds.width * 0.3)
                                .shadow(radius: 10)
                            
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                    
                    Text(event.eventName)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 0)
            .frame(width: 124)
            .clipped()
        }
    }
}
