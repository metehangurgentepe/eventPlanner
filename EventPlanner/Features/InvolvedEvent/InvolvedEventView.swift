//
//  InvolvedEventView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 19.08.2023.
//

import SwiftUI

struct InvolvedEventView: View {
    @StateObject var viewModel = InvolvedEventViewModel()
    @State private var isDetailEventViewPresented = false
    @State var selectedEvent : EventDatabase?
    @Environment(\.presentationMode) var presentationMode
    @GestureState private var dragOffset = CGSize.zero
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path:$path){
            ScrollView{
                if viewModel.isLoading {
                    ProgressView()
                } else{
                    if viewModel.eventList.count > 0 {
                        VStack{
                            ForEach(viewModel.eventList, id: \.id){ event in
                                HStack(spacing: 10) {
                                    NavigationLink(destination: DetailEventView(eventId: event.id, path: $path)) {
                                        AsyncImage(url: URL(string: event.eventPhoto)) { image in
                                            image
                                                .renderingMode(.original)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 70, height: 70)
                                                .clipped()
                                                .mask { RoundedRectangle(cornerRadius: 8, style: .continuous) }
                                            
                                        } placeholder: {
                                            Rectangle()
                                                .fill(.gray)
                                                .frame(width: 70, height: 70)
                                                .cornerRadius(12)
                                        }
                                        VStack(alignment: .leading) {
                                            Text(event.eventName)
                                                .font(.system(size: 16, weight: .medium, design: .default))
                                                .foregroundColor(.black)
                                            Text(viewModel.convertToTime(timeStr: event.eventStartTime)+", "+viewModel.convertToDate(dateStr: event.eventStartTime))
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                        .font(.subheadline)
                                    }
                                    Spacer()
                                }
                                .contextMenu {
                                    Button(action: {
                                        Task{
                                            try await viewModel.leaveEvent(eventId: event.id)
                                        }
                                    }) {
                                        Text(LocaleKeys.InvolvedEvent.leaveEvent.rawValue.locale())
                                        Image(systemName: "arrow.backward.circle")
                                    }
                                }
                                .padding(.horizontal)
                                Divider()
                            }
                        }
                        .navigationDestination(for: String.self) { text in
                            DetailEventView(eventId:text,path:$path)
                        }
                        .navigationDestination(for: AnnotationModel.self){ annotation in
                            DetailMapView(annotations: annotation)
                        }
                        
                        .padding(.vertical)
                        
                        
                        
                    } else{
                        // GeometryReader{ geometry in
                        VStack(spacing:UIScreen.main.bounds.height * 0.1){
                            Spacer()
                            Image("join_event")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width:UIScreen.main.bounds.width * 0.7)
                            //  .frame(width:geometry.size.width * 0.7)
                            
                            Text(LocaleKeys.InvolvedEvent.noEvent.rawValue.locale())
                                .font(.headline)
                            // .frame(width:geometry.size.width * 0.5)
                        }.padding(.top)
                    }
                    
                }
            }
            .navigationDestination(for: AnnotationModel.self){ annotation in
                DetailMapView(annotations: annotation)
            }
            .onAppear{
                Task{
                    try await viewModel.userInEvent()
                }
            }
            .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                if(value.startLocation.x < 60 &&
                   value.translation.width > 100) {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }))
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(viewModel.errorTitle.locale()),
                    message: Text(viewModel.errorMessage.locale()),
                    dismissButton: .default(Text(LocaleKeys.EditEvent.okButton.rawValue.locale())){
                        viewModel.showAlert = false
                    }
                )
            }
            .navigationTitle(LocaleKeys.Profile.involved.rawValue.locale())
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()

            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.title)
                    .foregroundStyle(.red)
            })
        }
        .navigationBarBackButtonHidden()
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct InvolvedEventView_Previews: PreviewProvider {
    static var previews: some View {
        InvolvedEventView()
    }
}
