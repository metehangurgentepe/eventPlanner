//
//  EditEventView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 25.07.2023.
//

import SwiftUI
import UIKit
import MapKit
import PhotosUI
import Firebase
import CustomAlert

struct EditEventView: View {
  //  @State var event : Event
    @ObservedObject var viewModel: EditEventViewModel
    @State var selectedIcon: String = "arrow.down"
    @EnvironmentObject var annotationStore: AnnotationStore
    @State var data : Data?
    @State var selectedItem : PhotosPickerItem?
    @State var formIsGood : Bool = false
    @State var showAlert : Bool = false
    @Environment(\.presentationMode) var presentationMode
    //@Binding var model = EditEventViewModel()
    let eventId: String// Store the eventId as a property
    @State private var isSaving = false
    @State var isEdited = false

    
    init(eventId: String) {
        self.eventId = eventId
        self._viewModel =  ObservedObject(wrappedValue: EditEventViewModel(eventId: eventId))
        self.data = nil
        print("buraya ne zamanlar girecek")
     //   removeAnnotation()
    }
    
    var body: some View {
        NavigationView{
            if let event = viewModel.event{
                ScrollView{
                    VStack{
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.33)
                                .foregroundColor(.white.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black.opacity(0.4),lineWidth: 1)
                                )
                                .padding(.horizontal)
                            VStack {
                                if !event.eventPhoto.isEmpty && data == nil{
                                    PhotosPicker(selection: $selectedItem){
                                        AsyncImage(url: URL(string:event.eventPhoto)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .cornerRadius(12)
                                                .scaleEffect(0.6)
                                                .frame(height:UIScreen.main.bounds.height * 0.45)
                                                .offset(y:UIScreen.main.bounds.height * 0.1)
                                            
                                        } placeholder: {
                                            Color.gray
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .scaleEffect(0.6)
                                                .frame(width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.height * 0.45)
                                                .offset(y:UIScreen.main.bounds.height * 0.1)
                                        }
                                        .padding(.horizontal)
                                    }
                                    .alert(isPresented: $showAlert) {
                                        Alert(
                                            title: Text(LocaleKeys.EditEvent.error.rawValue.locale()),
                                            message: Text(LocaleKeys.EditEvent.photoError.rawValue.locale()),
                                            dismissButton: .default(Text(LocaleKeys.EditEvent.okButton.rawValue.locale()))
                                        )
                                    }
                                    .onChange(of: selectedItem) { newValue in
                                        guard let item = selectedItem else { return }
                                        item.loadTransferable(type: Data.self) { result in
                                            switch result{
                                            case .success(let data):
                                                if let data = data{
                                                    self.data = data
                                                }
                                            case .failure(let error):
                                                self.showAlert = true
                                            }
                                        }
                                    }
                                    .padding()
                                }else if !event.eventPhoto.isEmpty && !data!.isEmpty{
                                    if let data = data{
                                        if let selectedImage = UIImage(data: data){
                                            Image(uiImage: selectedImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .cornerRadius(12)
                                                .scaleEffect(0.6)
                                                .frame(height:UIScreen.main.bounds.height * 0.45)
                                                .offset(y:UIScreen.main.bounds.height * 0.1)
                                        }
                                    }
                                }
                                // name textfield
                                GrayTextField(name: $viewModel.name, width: UIScreen.main.bounds.width * 0.48, height: UIScreen.main.bounds.height * 0.05, fieldWidth: 0.5, placeHolder: LocaleKeys.EditEvent.name.rawValue, keyboardType: .default)
                                
                                
                                // description text field
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 310, height: UIScreen.main.bounds.height * 0.1)
                                        .clipped()
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.black, lineWidth: 1) // Add the border here
                                        )
                                    
                                    TextField(LocaleKeys.EditEvent.desc.rawValue.locale(), text: $viewModel.desc,axis: .vertical)
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .frame(width: UIScreen.main.bounds.width * 0.7)
                                }
                            }
                            .offset(x: 0, y: -UIScreen.main.bounds.height * 0.18)
                        }
                        
                        // price and type
                        VStack{
                            VStack(spacing: 4){
                                HStack {
                                    Text(LocaleKeys.EditEvent.price.rawValue.locale())
                                    Spacer()
                                    Text(LocaleKeys.EditEvent.type.rawValue.locale())
                                    Spacer()
                                }
                                HStack{
                                    GrayTextField(name: $viewModel.price, width: UIScreen.main.bounds.width * 0.43, height: UIScreen.main.bounds.height * 0.07, fieldWidth: 0.4, placeHolder: LocaleKeys.EditEvent.price.rawValue, keyboardType: .numberPad)
                                        
                                    
                                    DropdownButton(selectedOption: $viewModel.selectedOption, selectedIcon: selectedIcon)
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            .padding(.leading)
                            
                            
                            // group chat link
                            VStack(spacing: 4){
                                HStack {
                                    Text(LocaleKeys.EditEvent.chatLink.rawValue.locale())
                                    Spacer()
                                }
                                GrayTextField(name: $viewModel.groupChatLink, width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.07, fieldWidth: 0.9,placeHolder: LocaleKeys.EditEvent.chat.rawValue, keyboardType: .URL)
                                    
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            
                            
                            // location
                            VStack(spacing: 4){
                                HStack {
                                    Text(LocaleKeys.EditEvent.location.rawValue.locale())
                                    Spacer()
                                }
                                HStack{
                                    GrayTextField(name: $viewModel.location, width: UIScreen.main.bounds.width * 0.43, height: UIScreen.main.bounds.height * 0.07, fieldWidth: 0.4, placeHolder: LocaleKeys.EditEvent.location.rawValue, keyboardType: .default)
                                        
                                        .padding(.trailing)
                                    Spacer()
                                    
                                    //go to button
                                    NavigationLink(destination: EditMapView(annotations: AnnotationModel(annotation: MKPointAnnotation(__coordinate: CLLocationCoordinate2D(latitude: viewModel.latitude, longitude: viewModel.longitude))), isEdited: isEdited)) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(.black)
                                                .frame(height: UIScreen.main.bounds.height * 0.07)
                                            
                                            Text(LocaleKeys.EditEvent.go.rawValue.locale())
                                                .foregroundColor(.white)
                                        }.overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke()
                                        )
                                    }.foregroundColor(.black)
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                            
                            // public or private event
                            Toggle(LocaleKeys.EditEvent.publicStr.rawValue.locale(), isOn: $viewModel.isPublic)
                                .frame(width: UIScreen.main.bounds.width * 0.9,height: UIScreen.main.bounds.height * 0.07)
                                .toggleStyle(SwitchToggleStyle(tint: .red))
                                
                            
                            // buttons
                            HStack{
                                CustomButton(textColor: .black, buttonColor: .white, text: LocaleKeys.EditEvent.cancel.rawValue, function: cancelButton)
                                    .padding(.trailing)
                                
                                CustomButton(textColor: .white, buttonColor: .black, text: LocaleKeys.EditEvent.save.rawValue, function:{
                                    isSaving = true // Kaydetme işlemi başladığında loading pop-up'ı göster
                                    let lastAnnotation = annotationStore.annotation
                                    print(lastAnnotation?.coordinate.latitude)
                                    print("konum burada")
                                    Task {
                                        await viewModel.updateEvent(
                                            name: viewModel.name,
                                            desc: viewModel.desc,
                                            isPublic: viewModel.isPublic,
                                            price: Int(viewModel.price)!,
                                            date: viewModel.event!.eventStartTime.description,
                                            type: viewModel.selectedOption,
                                            chatLink: viewModel.groupChatLink,
                                            location: viewModel.location,
                                            latitude: lastAnnotation?.coordinate.latitude ?? viewModel.event!.latitude,
                                            longitude: lastAnnotation?.coordinate.longitude ?? viewModel.event!.longitude,
                                            image: data != nil ? UIImage(data: data!) : nil,
                                            eventId: viewModel.event!.id.description
                                        )
                                        if viewModel.success{
                                            isSaving = false // Kaydetme işlemi tamamlandığında loading pop-up'ı gizle
                                            removeAnnotation()
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                })
                                .disabled(!formIsValid).opacity(formIsValid ? 1 : 0.5)
                                .foregroundColor(.black)
                                .alert(isPresented: $viewModel.showAlert){
                                    Alert(
                                        title: Text(LocaleKeys.AddUser.error.rawValue.locale()),
                                        message: Text(viewModel.errorMessage.locale()),
                                        dismissButton: .default(Text(LocaleKeys.addEvent.okButton.rawValue.locale())){
                                            viewModel.showAlert = false
                                        }
                                    )
                                }
                            }
                            .customAlert(isPresented: $isSaving) {
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.blue)
                                    Text(LocaleKeys.EditEvent.saving.rawValue.locale())
                                        .font(.headline)
                                }
                            } actions: {}
                            .padding(.horizontal)
                            .frame(width:UIScreen.main.bounds.width * 0.9)
                            .padding(.top)
                        }
                        .offset(y:-UIScreen.main.bounds.height * 0.15)
                    }
                }.navigationTitle(LocaleKeys.EditEvent.title.rawValue.locale())
            }
        }
    }
    func removeAnnotation() {
        annotationStore.annotation = nil
    }
    func cancelButton(){
        removeAnnotation()
        presentationMode.wrappedValue.dismiss()
    }
}
extension EditEventView: EditEventFormProtocol {
    var formIsValid: Bool {
        return  !viewModel.desc.isEmpty && !viewModel.name.isEmpty && isNumericString(viewModel.price) && !viewModel.price.isEmpty && !viewModel.location.isEmpty
    }
}




