//
//  SavedEventView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 24.07.2023.
//

import SwiftUI

struct SavedEventView: View {
    @StateObject var viewModel = SavedEventViewModel()
    @State private var didAppear : Bool = false
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path:$path){
            ScrollView{
                VStack{
                    if viewModel.events.count > 0 {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                            ForEach(viewModel.events) { event in // Replace with your data model here
                                EventView(event: event, path: $path)
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
                
            }
            .alert(isPresented: $viewModel.showAlert, content: {
                Alert(
                    title: Text(viewModel.errorMessage),
                    message: Text(viewModel.errorMessage),
                    dismissButton:.default(Text(LocaleKeys.addEvent.okButton.rawValue.locale())){
                        viewModel.showAlert = false
                    }
                )})
            .navigationTitle(LocaleKeys.Saved.title.rawValue.locale())
            .onAppear{
                Task{
                    try await viewModel.getSavedEvents()
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SavedEventView_Previews: PreviewProvider {
    static var previews: some View {
        SavedEventView()
    }
}

struct EventView: View {
    let event: EventDatabase
   @Binding var path : NavigationPath
    var body: some View {
        NavigationLink(value: event.id) {
            ZStack {
                VStack {
                    ZStack{
                        AsyncImage(url: URL(string: event.eventPhoto)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .shadow(color: Color(.tertiaryLabel).opacity(0.5), radius: 8, x: 0, y: 4)
                                .mask { RoundedRectangle(cornerRadius: 14, style: .continuous)}
                                .cornerRadius(12)
                                .frame(width:UIScreen.main.bounds.width * 0.27,height: UIScreen.main.bounds.width * 0.27)
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
            .frame(width: UIScreen.main.bounds.width * 0.4)
            .clipped()
        }.navigationDestination(for: String.self) { text in
            DetailEventView(eventId: text, path: $path)
        }
    }
}
