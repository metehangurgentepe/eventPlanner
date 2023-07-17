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


struct AddEvent2View: View {
    var eventName: String
    var eventType: String
    var price: String
    @State var selectedItem : [PhotosPickerItem] = []
    @State var data : Data?
    @State private var description = ""
    @State private var location = ""
    @State private var isToggled = false
    @State private var imageUrl = ""
    @State private var eventTime = Date()
    @ObservedObject private var eventVM = EventViewModel.shared
    let storageRef = Storage.storage().reference()
    @State private var selectedImage: UIImage?
    @EnvironmentObject var annotationStore: AnnotationStore
    @State private var showAlert = false // Add a state variable to control the alert
    @EnvironmentObject var authVM : AuthViewModel
    @StateObject var alertVM = AlertModel(success: false, message: "Error", title: "Form is not valid")
    @State var success : Bool = false
    
    var body: some View {
        
        NavigationView{
            VStack{
                // PHOTO PICKER
                if let data = data{
                    if let selectedImage = UIImage(data: data){
                        Image(uiImage: selectedImage)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width * 0.6,height:UIScreen.main.bounds.height * 0.25,alignment: .center)
                            .scaledToFit()
                    }
                }
                if data == nil{
                    PhotosPicker(selection: $selectedItem){
                        VStack(spacing:15){
                            Image(systemName: IconItemString.EventView.photo.rawValue)
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width * 0.4,height: UIScreen.main.bounds.height * 0.2)
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
                                print(error)
                            }
                        }
                    }
                    .padding()
                }
                
                // DESCRIPTION
                
                CustomTextField(imageName: IconItemString.EventView.description.rawValue, placeholder: LocaleKeys.addEvent.description.rawValue, text: $description)
                
                
                //LOCATION
                
                
                
                HStack{
                    CustomTextField(imageName: IconItemString.EventView.locationTextField.rawValue, placeholder: LocaleKeys.addEvent.location.rawValue, text: $location)
                    
                    
                    NavigationLink(destination:AddMapView()) {
                        Image(systemName: IconItemString.EventView.location.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 50)
                    }
                    .padding(.horizontal)
                    .foregroundColor(.indigo)
                }
                
                
                // DATE PICKER
                DatePicker(LocaleKeys.addEvent.time.rawValue.locale(), selection: $eventTime)
                    .datePickerStyle(.compact)
                    .padding()
                    .foregroundColor(.blue)
                
                // SWITCH
                
                Toggle(LocaleKeys.addEvent.publicEvent.rawValue.locale(), isOn: $isToggled)
                    .padding()
                    .foregroundColor(.blue)
                
                //BUTTON
                
                Button {
                    Task {
                        if data == nil {
                            showAlert = true // Show the alert if the image is not selected
                            
                        } else {
                            if let image = UIImage(data: data!) {
                                do {
                                    let imageUrl = await eventVM.saveImage(image: image)
                                    
                                    let now = Date() // Get the current time
                                    
                                    if eventTime < now {
                                        // Show an alert or handle the case when eventTime is before the current time
                                        showAlert = true
                                    } else {
                                        let lastAnnotation = annotationStore.annotation
                                        if lastAnnotation != nil {
                                            try await eventVM.createEvent(
                                                name: eventName,
                                                type: eventType,
                                                price: price,
                                                description: description,
                                                location: location,
                                                isPublic: isToggled,
                                                date: eventTime,
                                                imageUrl: imageUrl,
                                                latitude: (lastAnnotation!.coordinate.latitude),
                                                longitude: lastAnnotation!.coordinate.longitude,
                                                phoneNumber: authVM.currentUser!.phoneNumber
                                            )
                                            eventVM.success = true
                                        } else {
                                            
                                        }
                                    }
                                    
                                } catch {
                                    showAlert = true
                                    
                                }
                            }
                        }
                    }
                } label: {
                    Text(LocaleKeys.addEvent.createEvent.rawValue.locale())
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.purple)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .padding()
                .alert(isPresented: $showAlert, content: {
                    Alert(
                        title: Text("Please try again"),
                        message: Text(alertVM.title),
                        dismissButton: .default(Text(LocaleKeys.addEvent.okButton.rawValue.locale()))
                    )
                })
            }
        }.navigationBarBackButtonHidden()
    }
}

extension AddEvent2View: EventFormProtocol {
    var formIsValid: Bool {
        return  !description.isEmpty && !location.isEmpty && showAlert
    }
}


struct AddEvent2View_Previews: PreviewProvider {
    static var previews: some View {
        AddEvent2View(eventName: "equip picnic", eventType: "picnic", price: "100")
    }
}
