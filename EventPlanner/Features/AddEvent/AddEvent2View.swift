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
    @State var selectedItem : [PhotosPickerItem] = []
    @State var data : Data?
    @State private var location = ""
    @State private var isToggled = false
    @State private var imageUrl = ""
    @State private var eventTime = Date()
    @ObservedObject private var eventVM = EventViewModel.shared
    let storageRef = Storage.storage().reference()
    @State private var selectedImage: UIImage?
    @EnvironmentObject var annotationStore: AnnotationStore
    @State private var showAlert = false // Add a state variable to control the alert
    @EnvironmentObject var authVM : AuthManager
    @State var success : Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State var price = ""
    @State var errorMessage = ""
    @State var intersitial : GADInterstitialAd?
    var isNavigatedToHomeView : Bool
    @State private var isSaving = false
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(spacing: UIScreen.main.bounds.height * 0.04){
                    // PHOTO PICKER
                    if let data = data{
                        if let selectedImage = UIImage(data: data){
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .frame(width: UIScreen.main.bounds.width * 0.6,height:UIScreen.main.bounds.height * 0.25,alignment: .center)
                        }
                    }
                    if data == nil{
                        PhotosPicker(selection: $selectedItem){
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
                        }.onChange(of: selectedItem) { newValue in
                            guard let item = selectedItem.first else { return }
                            item.loadTransferable(type: Data.self) { result in
                                switch result{
                                case .success(let data):
                                    if let data = data{
                                        self.data = data
                                    }
                                case .failure(let error):
                                    self.showAlert = true
                                    errorMessage = LocaleKeys.EditEvent.photoError.rawValue
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
                    
                    
                    BorderTextField(name: $price, width: UIScreen.main.bounds.width * 0.88, height: UIScreen.main.bounds.height * 0.07, placeHolder: LocaleKeys.addEvent.price.rawValue, iconName: IconItemString.EventView.price.rawValue,keyboardType: .numberPad)
                    
                    
                    HStack(spacing: UIScreen.main.bounds.width * 0.02){
                        GrayTextField(name: $location, width: UIScreen.main.bounds.width * 0.43, height: UIScreen.main.bounds.height * 0.07, fieldWidth: 0.4, placeHolder: LocaleKeys.addEvent.location.rawValue, keyboardType: .default)
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
                    DatePicker(LocaleKeys.addEvent.time.rawValue.locale(), selection: $eventTime)
                        .datePickerStyle(.compact)
                        .foregroundColor(.indigo)
                        .frame(width: UIScreen.main.bounds.width * 0.88)
                    
                    // SWITCH
                    Group{
                        Toggle(LocaleKeys.addEvent.publicEvent.rawValue.locale(), isOn: $isToggled)
                            .foregroundColor(.indigo)
                            .frame(width: UIScreen.main.bounds.width * 0.88)
                        
                        if isNavigatedToHomeView {
                            NavigationLink(destination: HomeView(), isActive: $success) {
                                EmptyView()
                            }.frame(width: 2,height: 2)
                        } else {
                            NavigationLink(destination: MyEventsView(), isActive: $success) {
                                EmptyView()
                            }.frame(width: 2,height: 2)
                        }
                    }
                    //BUTTON
                    Button {
                        Task {
                            switch true {
                            case data == nil:
                                showAlert = true
                                self.errorMessage = LocaleKeys.addEvent.photoError.rawValue
                                
                            case eventTime < Date():
                                showAlert = true
                                self.errorMessage = LocaleKeys.addEvent.timeError.rawValue
                                
                            case price.isEmpty:
                                showAlert = true
                                self.errorMessage = LocaleKeys.addEvent.priceError.rawValue
                                
                            case location.isEmpty:
                                showAlert = true
                                self.errorMessage = LocaleKeys.addEvent.locationError.rawValue
                                
                            case annotationStore.annotation == nil:
                                showAlert = true
                                self.errorMessage = LocaleKeys.addEvent.selectLocationError.rawValue
                                
                            default:
                                do {
                                    isSaving = true
                                    let image = UIImage(data: data!)
                                    let imageUrl = await eventVM.saveImage(image: image!)
                                    try await eventVM.createEvent(
                                        name: eventName,
                                        type: eventType,
                                        price: price,
                                        description: description,
                                        location: location,
                                        isPublic: isToggled,
                                        date: eventTime,
                                        imageUrl: imageUrl,
                                        latitude: (annotationStore.annotation!.coordinate.latitude),
                                        longitude: annotationStore.annotation!.coordinate.longitude,
                                        phoneNumber: authVM.currentUser!.phoneNumber
                                    )
                                    removeAnnotation()
                                    isSaving = false
                                    self.success = true
                                    /*  if  intersitial != nil {
                                     intersitial!.present(fromRootViewController: (UIApplication.shared.windows.first?.rootViewController)!)
                                     } */
                                } catch {
                                    self.errorMessage = LocaleKeys.addEvent.creationError.rawValue
                                }
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
                    .alert(isPresented: $showAlert, content: {
                        Alert(
                            title: Text(LocaleKeys.addEvent.errorTitle.rawValue.locale()),
                            message: Text(self.errorMessage.locale()),
                            dismissButton: .default(Text(LocaleKeys.addEvent.okButton.rawValue.locale())) {
                                showAlert = false
                            }
                        )
                    })
                    .customAlert(isPresented: $isSaving ) {
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
            }.navigationBarItems(leading: Button(action: {
                removeAnnotation()
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.title)
            })
        }.navigationBarBackButtonHidden()
    }
    func removeAnnotation() {
        annotationStore.annotation = nil
    }
}


extension AddEvent2View: EventFormProtocol {
    var formIsValid: Bool {
        return  !description.isEmpty && !location.isEmpty && isNumericString(price)
    }
}
// price is numeric?
func isNumericString(_ string: String) -> Bool {
    let numericRegex = "^[0-9]+$"
    let numericPredicate = NSPredicate(format: "SELF MATCHES %@", numericRegex)
    return numericPredicate.evaluate(with: string)
}


struct AddEvent2View_Previews: PreviewProvider {
    static var previews: some View {
        AddEvent2View(eventName: "equip picnic", eventType: "picnic", description: "descr", isNavigatedToHomeView: true)
    }
}
