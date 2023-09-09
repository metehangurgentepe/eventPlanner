//
//  DistanceForLocation.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 23.08.2023.
//

import SwiftUI

struct DistanceForLocationView: View {
    @State var distance: Double
    @State private var isEditing = false
    let userDefaults = UserDefaults.standard
    @StateObject var viewModel = DistanceForLocationViewModel()
    @Environment(\.presentationMode) var presentationMode
    @GestureState private var dragOffset = CGSize.zero

   
    init() {
            _distance = State(initialValue: userDefaults.double(forKey: "Distance"))
    }
    
    var body: some View {
        NavigationView{
            Group{
                GeometryReader{ geometry in
                    VStack{
                        Image("distance")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width * 0.7)
                        
                        Text(LocaleKeys.Distance.subtitle.rawValue.locale())
                            .padding(.top)
                            .frame(width: geometry.size.width * 0.7)
                        
                        Spacer()
                        
                        VStack {
                            Slider(
                                value: $viewModel.distance,
                                in: 10...5000,
                                step: 10
                            ) {
                            } minimumValueLabel: {
                                Text("10 km")
                            } maximumValueLabel: {
                                Text("5000 km")
                            } onEditingChanged: { editing in
                                userDefaults.set(viewModel.distance, forKey: "Distance")
                                print(viewModel.distance)
                                isEditing = editing
                            }
                            .foregroundColor(.red)
                            
                            Text("\(viewModel.distance.description) km")
                                .foregroundColor(isEditing ? .blue : .black)
                        }.padding(.horizontal)
                        
                        Spacer()
                        
                        Button{
                            userDefaults.set(viewModel.distance, forKey: "Distance")
                        } label:{
                            ZStack{
                                Capsule()
                                    .fill(.red)
                                Text(LocaleKeys.EditProfile.saveButton.rawValue.locale())
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }.frame(width:UIScreen.main.bounds.width * 0.85,height:UIScreen.main.bounds.height * 0.06)
                        }.padding(.top)

                    }
                    .frame(height: geometry.size.height * 0.7)
                    .padding(.top)
                    .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                        if(value.startLocation.x < 60 &&
                           value.translation.width > 100) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }))
                }
            }
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.title)
                    .foregroundStyle(.red)
            })
            .navigationTitle(LocaleKeys.Distance.title.rawValue.locale())
            
        }.navigationBarBackButtonHidden()
            .navigationViewStyle(StackNavigationViewStyle())
    }
}

