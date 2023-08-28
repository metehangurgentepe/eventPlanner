//
//  CreatedEventView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 25.07.2023.
//

import SwiftUI

struct CreatedEventView: View {
    @StateObject var viewModel = CreatedEventViewModel()
    @State private var isEditEventViewPresented = false
    @State private var isDetailEventViewPresented = false
    @State private var isAddUserEventViewPresented = false
    @State var selectedEventId : String = ""
    @State var selectedEvent : Event?
    @Environment(\.presentationMode) var presentationMode
    @GestureState private var dragOffset = CGSize.zero
    
    
    init(){
        viewModel.getCreatedEvent()
    }
    var body: some View {
        VStack{
            ScrollView{
                if viewModel.isLoading{
                    ProgressView()
                } else{
                    VStack(spacing: 40) {
                        VStack {
                            if viewModel.createdEventList.count > 0{
                                ForEach(viewModel.createdEventList) { event in // Replace with your data model here
                                    HStack(spacing: 10) {
                                        Button{
                                            self.selectedEvent = event
                                            isDetailEventViewPresented = true
                                        } label: {
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
                                        Menu {
                                            // edit Button
                                            Button{
                                                self.selectedEvent = event
                                                isEditEventViewPresented = true
                                            } label: {
                                                Label(LocaleKeys.CreatedEvent.edit.rawValue.locale(), systemImage: "square.and.pencil")
                                            }
                                            //add user
                                            Button {
                                                self.selectedEventId = event.id
                                                isAddUserEventViewPresented = true
                                            } label: {
                                                Label(LocaleKeys.CreatedEvent.users.rawValue.locale(), systemImage: "person.badge.plus")
                                            }
                                            //delete button
                                            Button(role: .destructive) {
                                                viewModel.deleteEvent(eventId: event.id)
                                            } label: {
                                                Label(LocaleKeys.CreatedEvent.delete.rawValue.locale(), systemImage: "trash")
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(Color(.displayP3, red: 234/255, green: 76/255, blue: 97/255))
                                                .frame(width:UIScreen.main.bounds.width * 0.08)
                                        }
                                    }
                                    Divider()
                                }
                            } else{
                                VStack(spacing:20){
                                    Image("created_events")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: UIScreen.main.bounds.width * 0.7)
                                    Text(LocaleKeys.CreatedEvent.noEvent.rawValue.locale())
                                        .font(.headline)
                                        .padding()
                                    Spacer()
                                    NavigationLink(destination: AddEventView(selectedOption: LocaleKeys.addEvent.select.rawValue, selectedIcon: "arrow.down", isNavigatedToHomeView: false)){
                                        ZStack{
                                            Capsule()
                                            Text(LocaleKeys.CreatedEvent.addEvent.rawValue.locale())
                                                .font(.headline)
                                                .foregroundColor(.black)
                                        }.frame(width:UIScreen.main.bounds.width * 0.85,height:UIScreen.main.bounds.height * 0.06)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                    }
                    .padding(.top)
                }
            }
            .onAppear{
                viewModel.getCreatedEvent()
            }
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.title)
            })
            .navigationBarTitle(LocaleKeys.CreatedEvent.title.rawValue.locale())
            .onChange(of: isAddUserEventViewPresented || isEditEventViewPresented || isDetailEventViewPresented){isPresented in
                if !isPresented {
                    // Reset the selectedEventId when the AddUserEventView is dismissed
                    selectedEventId = ""
                }
            }
            .refreshable{
                viewModel.getCreatedEvent()
            }
            .sheet(isPresented: $isDetailEventViewPresented) {
                DetailEventView(eventId: selectedEvent?.id ?? "")
            }.sheet(isPresented: $isEditEventViewPresented) {
                EditEventView(eventId: selectedEvent?.id ?? "")
            }.sheet(isPresented: $isAddUserEventViewPresented) {
                AddUserEventView(eventId: selectedEventId)
            }.navigationBarBackButtonHidden()
        }
        .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
            if(value.startLocation.x < 60 &&
               value.translation.width > 100) {
                self.presentationMode.wrappedValue.dismiss()
            }
        }))
    }
}

/*struct CreatedEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreatedEventView( selectedEventId: "")
    }
} */
