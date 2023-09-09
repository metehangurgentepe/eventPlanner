//
//  AddEvent2View.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 9.07.2023.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import MapKit
import GoogleMobileAds
import CustomAlert
import Photos

struct AddEvent2View: View {
    var eventName: String
    var eventType: String
    var description: String
   // var isNavigatedToHomeView : Bool
    @EnvironmentObject var annotationStore: AnnotationStore
    @State var intersitial : GADInterstitialAd?
    @StateObject var viewModel = Add2EventViewModel()
    @GestureState private var dragOffset = CGSize.zero
    @Binding var path : NavigationPath
    
    var body: some View {
            ScrollView{
                VStack(spacing: UIScreen.main.bounds.height * 0.04){
                    // PHOTO PICKER
                    if let data = viewModel.data{
                        if let selectedImage = UIImage(data: data){
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .frame(width: UIScreen.main.bounds.width * 0.6,height:UIScreen.main.bounds.height * 0.25,alignment: .center)
                        }
                    }
                    if viewModel.data == nil{
                        PhotosPicker(selection: $viewModel.selectedItem){
                            VStack(spacing:15){
                                Image(IconItemString.EventView.photo.rawValue)
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: UIScreen.main.bounds.width * 0.6)
                                    .foregroundColor(.black)
                                
                                Text(LocaleKeys.addEvent.selectImage.rawValue.locale())
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                            }
                        }.onChange(of: viewModel.selectedItem) { newValue in
                            guard let item = viewModel.selectedItem.first else { return }
                            item.loadTransferable(type: Data.self) { result in
                                switch result{
                                case .success(let data):
                                    if let data = data{
                                        self.viewModel.data = data
                                    }
                                case .failure(_):
                                    self.viewModel.showAlert = true
                                    viewModel.errorMessage = LocaleKeys.EditEvent.photoError.rawValue
                                }
                            }
                        }
                        /*  .alert(isPresented: $showAlert) {
                         Alert(
                         title: Text(LocaleKeys.EditEvent.error.rawValue.locale()),
                         message: Text(LocaleKeys.EditEvent.photoError.rawValue.locale()),
                         dismissButton: .default(Text(LocaleKeys.EditEvent.okButton.rawValue.locale()))
                         )
                         }*/
                        .padding()
                    }
                    
                    // DESCRIPTION
                    
                    
                    BorderTextField(name: $viewModel.price, width: UIScreen.main.bounds.width * 0.88, height: UIScreen.main.bounds.height * 0.07, placeHolder: LocaleKeys.addEvent.price.rawValue, iconName: IconItemString.EventView.price.rawValue,keyboardType: .numberPad)
                    
                    
                    HStack(spacing: UIScreen.main.bounds.width * 0.02){
                        GrayTextField(name: $viewModel.location, width: UIScreen.main.bounds.width * 0.43, height: UIScreen.main.bounds.height * 0.07, fieldWidth: 0.4, placeHolder: LocaleKeys.addEvent.location.rawValue, keyboardType: .default)
                        //go to button
                        NavigationLink(destination: MapUIView(latitude: annotationStore.annotation?.coordinate.latitude ?? 0.0, longitude: annotationStore.annotation?.coordinate.longitude ?? 0.0)) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.black)
                                    .frame(width: UIScreen.main.bounds.width * 0.43,height: UIScreen.main.bounds.height * 0.07)
                                Text(LocaleKeys.addEvent.addButton.rawValue.locale())
                                    .foregroundColor(.white)
                            }.overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke()
                            )
                        }.foregroundColor(.black)
                    }
                    
                    // DATE PICKER
                    DatePicker(LocaleKeys.addEvent.time.rawValue.locale(), selection: $viewModel.eventTime)
                        .datePickerStyle(.compact)
                        .foregroundColor(.indigo)
                        .frame(width: UIScreen.main.bounds.width * 0.88)
                    
                    // SWITCH
                    Group{
                        Toggle(LocaleKeys.addEvent.publicEvent.rawValue.locale(), isOn: $viewModel.isPublic)
                            .foregroundColor(.indigo)
                            .frame(width: UIScreen.main.bounds.width * 0.88)
                        
                       /* if isNavigatedToHomeView {
                            NavigationLink(destination: HomeView(), isActive: $viewModel.success) {
                                EmptyView()
                            }.frame(width: 2,height: 2)
                        } else {
                            NavigationLink(destination: MyEventsView(), isActive: $viewModel.success) {
                                EmptyView()
                            }.frame(width: 2,height: 2)
                        } */
                        
                    }
                    //BUTTON
                    Button {
                        Task {
                            if let annotation = annotationStore.annotation{
                                try await viewModel.createEvent(name:eventName,type:eventType,desc:description,annotation:annotation)
                                AnalyticsManager.shared.logEvent(name: "AddEventView_CreateButtonClicked")
                                removeAnnotation()
                                if viewModel.success{
                                    path = NavigationPath()
                                }
                            } else {
                                viewModel.showAlert = true
                                viewModel.errorMessage = LocaleKeys.addEvent.selectLocationError.rawValue
                            }
                        }
                    }label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black)
                                .frame(width: UIScreen.main.bounds.width * 0.9,height: UIScreen.main.bounds.height * 0.08)
                            Text(LocaleKeys.addEvent.createEvent.rawValue.locale())
                                .foregroundColor(.white)
                        }.overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke()
                        )
                    }
                    .alert(isPresented: $viewModel.showAlert, content: {
                        Alert(
                            title: Text(LocaleKeys.addEvent.errorTitle.rawValue.locale()),
                            message: Text(self.viewModel.errorMessage.locale()),
                            dismissButton: .default(Text(LocaleKeys.addEvent.okButton.rawValue.locale())) {
                                viewModel.showAlert = false
                            }
                        )
                    })
                    .customAlert(isPresented: $viewModel.isSaving ) {
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.blue)
                            Text(LocaleKeys.EditEvent.saving.rawValue.locale())
                                .font(.headline)
                        }
                    } actions: {}
                        .foregroundColor(.white)
                }
                .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                    if(value.startLocation.x < 60 &&
                       value.translation.width > 100) {
                        removeAnnotation()
                        path.removeLast()
                    }
                }))
            }
            .navigationBarItems(leading: Button(action: {
                removeAnnotation()
                path.removeLast()
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
            }).navigationBarBackButtonHidden()
    }
    func removeAnnotation() {
        annotationStore.annotation = nil
    }
}


extension AddEvent2View: AddEvent2FormProtocol {
    var formIsValid: Bool {
        return !viewModel.location.isEmpty && isNumericString(viewModel.price)
    }
}
// price is numeric?
func isNumericString(_ string: String) -> Bool {
    let numericRegex = "^[0-9]+$"
    let numericPredicate = NSPredicate(format: "SELF MATCHES %@", numericRegex)
    return numericPredicate.evaluate(with: string)
}


/*struct AddEvent2View_Previews: PreviewProvider {
    static var previews: some View {
        AddEvent2View(eventName: "equip picnic", eventType: "picnic", description: "descr", path: <#Binding<NavigationPath>#>)
    }
} */
