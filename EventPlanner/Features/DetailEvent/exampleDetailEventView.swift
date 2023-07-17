//
//  exampleDetailEventView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 16.07.2023.
//

import SwiftUI
import CoreLocation
import MapKit

struct exampleDetailEventView: View {
    @ObservedObject var eventVM = EventViewModel()
    @State private var isLoading = true
    @State private var event: Event?
    @State private var error: Error?
    @EnvironmentObject var authVM : AuthViewModel
    @State var user : User?
    @State private var containsUser = false
    
    var chosenEvent : Event
    
    
    var body: some View {
        NavigationView{
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
                        HStack {
                            Image(systemName: "arrow.backward")
                                .font(.title3)
                                .padding(11)
                                .background {
                                    Circle()
                                        .fill(Color(.systemBackground))
                                }
                            Spacer()
                        }
                        .padding()
                        .padding(.top, 44)
                    }
                    .frame(width: 390, height: 320)
                    .clipped()
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(chosenEvent.eventName)
                                .font(.system(size: 29, weight: .semibold, design: .default))
                            Spacer()
                            HStack(alignment: .firstTextBaseline, spacing: 3) {
                                Image(systemName: "star.fill")
                                    .symbolRenderingMode(.multicolor)
                                Text("4.55")
                                    .foregroundColor(.secondary)
                            }
                            .font(.system(.subheadline, weight: .medium))
                        }
                        Text(chosenEvent.location)
                            .font(.system(.callout, weight: .medium))
                        Text(chosenEvent.description)
                            .font(.system(.callout).width(.condensed))
                            .padding(.vertical)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    VStack(alignment: .leading, spacing: 15) {
                        Text("HIGHLIGHTS")
                            .kerning(2.0)
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(.secondary)
                        
                        
                        Group{
                            EventPropertiesRow(imageName: "network", text: chosenEvent.eventType)
                            EventPropertiesRow(imageName: "calendar", text: eventVM.convertToDate(dateStr:chosenEvent.eventStartTime))
                            EventPropertiesRow(imageName: "clock", text: eventVM.convertToTime(timeStr: chosenEvent.eventStartTime))
                           
                            EventPropertiesRow(imageName: "dollarsign", text: String(chosenEvent.price))
                            EventPropertiesRow(imageName: "phone", text: chosenEvent.phoneNumber)
                            
                        }
                        HStack{
                            EventPropertiesRow(imageName:"location" , text: chosenEvent.location)
                            
                   /*         NavigationLink(destination: MapView(annotations: AnnotationModel(annotation: MKPointAnnotation(CLLocationCoordinate2D(latitude: chosenEvent.latitude, longitude: chosenEvent.longitude))))) {
                                Text("Go to location")
                            }
                            
                            */
                            NavigationLink(destination:DetailMapView(annotations: AnnotationModel(annotation: MKPointAnnotation(__coordinate:CLLocationCoordinate2D(latitude: chosenEvent.latitude, longitude: chosenEvent.longitude))))) {
                                Text("Go to location")
                            }
                        }
                        
                    }
                    .padding(.horizontal, 24)
                    VStack(spacing: 14) {
                        
                        Text("Reserve")
                            .font(.system(.title3, weight: .medium))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(.orange)
                            .foregroundColor(.white)
                            .mask {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                            }
                    }
                    .padding(.vertical, 28)
                }
            }
        }
    }
}

struct exampleDetailEventView_Previews: PreviewProvider {
    static var previews: some View {
        exampleDetailEventView(chosenEvent: Event(id: "aefaf", eventName: "asfd", description: "asdfas", eventStartTime: "sdfa", eventLeadUser: "safas", eventPhoto: "asf", eventType: "asf", users: ["asf"], location: "asf", publicEvent: true, price: 30, phoneNumber: "dsfa", latitude: 35, longitude: 35))
    }
}
