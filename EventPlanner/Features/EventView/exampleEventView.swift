//
//  exampleEventView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 16.07.2023.
//

import SwiftUI

struct EventView: View {
    @ObservedObject  var eventVM = EventViewModel()
    @State private var model : [EventModel] = []
    
    init(){
        eventVM.getUpcomingList()
        eventVM.getBeforeList()
        self.model = [EventModel(title: "Upcoming", list: eventVM.upcomingList),EventModel(title: "Last", list:eventVM.beforeList )]
    }
    
    var body: some View {
        if eventVM.upcomingList.count == 0{
            VStack{
                Image("event")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.4,height: UIScreen.main.bounds.height * 0.4)
                
                Text("There is no event")
                    .font(.title2)
                Spacer()
            }.frame(width: UIScreen.main.bounds.width * 0.8,height: UIScreen.main.bounds.height * 0.3)
        } else{
            NavigationView{
                ScrollView {
                    VStack {
                        Text("Your Events")
                            .font(.system(.largeTitle, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .clipped()
                            .padding(.bottom, 8)
                        
                        
                            .padding(.horizontal)
                            .padding(.bottom)
                        VStack(spacing: 40) {
                            ForEach(model) { item in // Replace with your data model here
                                VStack {
                                    Text(item.title.uppercased())
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .clipped()
                                        .font(.system(.subheadline, weight: .medium).width(.expanded))
                                        .foregroundColor(.pink)
                                    
                                    VStack(spacing: 7) {
                                        ForEach(item.list) { event in // Replace with your data model here
                                            NavigationLink(destination: exampleDetailEventView(chosenEvent:event)) {
                                                HStack() {
                                                    AsyncImage(url: URL(string:event.eventPhoto)) { image in
                                                        image
                                                            .renderingMode(.original)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 70, height: 70)
                                                            .clipped()
                                                            .mask { RoundedRectangle(cornerRadius: 8, style: .continuous) }
                                                        
                                                    } placeholder: {
                                                        Color.gray
                                                            .frame(width: 70, height: 70)
                                                    }
                                                    
                                                    VStack(alignment: .leading) {
                                                        Text(event.eventName)
                                                            .font(.system(size: 16, weight: .medium, design: .default))
                                                        HStack{
                                                            Text("\(eventVM.convertToDate(dateStr: event.eventStartTime)),")
                                                                .font(.footnote)
                                                                .foregroundColor(.secondary)
                                                            Text(eventVM.convertToTime(timeStr: event.eventStartTime))
                                                                .font(.footnote)
                                                                .foregroundColor(.secondary)
                                                        }
                                                        
                                                    }
                                                    .font(.subheadline)
                                                    Spacer()
                                                    Image(systemName: "ellipsis")
                                                        .foregroundColor(Color(.displayP3, red: 234/255, green: 76/255, blue: 97/255))
                                                        .font(.title3)
                                                }
                                                Divider()
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .padding(.top, 20)
                    .padding(.bottom, 50)
                }.onAppear {
                    eventVM.getUpcomingList()
                    eventVM.getBeforeList()
                    self.model = [EventModel(title: "Upcoming", list: eventVM.upcomingList),
                                  EventModel(title: "Last", list: eventVM.beforeList)]
                }
            }
        }
    }
}

struct exampleEventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView()
    }
}
