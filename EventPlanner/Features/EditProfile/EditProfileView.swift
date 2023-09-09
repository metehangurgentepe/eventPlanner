//
//  EditProfileView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 23.07.2023.
//

import SwiftUI
import PhotosUI
import FirebaseCore
import CustomAlert

struct EditProfileView: View {
    @State var name : String
    @State var email : String
    @State var password = ""
    @State var phoneNumber : String
    @StateObject var viewModel = EditProfileViewModel()
    @State var data : Data?
    @State var selectedItem : [PhotosPickerItem] = []
    @State var imageUrl: String
    @State var isFirstTime: Bool = false
    @State private var isSaving = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView{
        VStack{
            if data == nil && imageUrl == ""{
                PhotosPicker(selection: $selectedItem){
                    VStack{
                        ZStack{
                            Circle()
                            Image(systemName: IconItemString.EditProfile.camera.rawValue)
                                .imageScale(.large)
                                .symbolRenderingMode(.monochrome)
                                .foregroundColor(Color(.systemBackground))
                        }
                        Text(LocaleKeys.EditProfile.image.rawValue.locale())
                            .font(.largeTitle)
                    }
                    .foregroundColor(.black)
                    .frame(height: UIScreen.main.bounds.height * 0.2)
                }.onChange(of: selectedItem) { newValue in
                    if let item = newValue.first {
                        item.loadTransferable(type: Data.self) { result in
                            switch result {
                            case .success(let data):
                                if let data = data {
                                    self.data = data
                                    isFirstTime = true
                                }
                            case .failure(let error):
                                viewModel.showPhotoAlert = true
                                print(error)
                            }
                        }
                    } else {
                        viewModel.showPhotoAlert = true
                    }
                }
                .padding()
            }else if imageUrl.isEmpty && !data!.isEmpty{
                if let data = data{
                    if let selectedImage = UIImage(data: data){
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(width: UIScreen.main.bounds.width * 0.2, height:UIScreen.main.bounds.height * 0.20)
                    }
                }
            }
            else if !imageUrl.isEmpty && data == nil{
                PhotosPicker(selection: $selectedItem){
                    AsyncImage(url: URL(string:imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.5,minHeight:UIScreen.main.bounds.height * 0.35,maxHeight:UIScreen.main.bounds.height * 0.5)
                        
                    } placeholder: {
                        Color.gray
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.3)
                            .clipShape(Circle())
                    }
                    .padding(.horizontal)
                }
                .onChange(of: selectedItem) { newValue in
                    guard let item = selectedItem.first else { return }
                    item.loadTransferable(type: Data.self) { result in
                        switch result{
                        case .success(let data):
                            if let data = data{
                                self.data = data
                            }
                        case .failure(let error):
                            viewModel.showPhotoAlert = true
                            print(error)
                            
                        }
                    }
                }
                .alert(isPresented: $viewModel.showPhotoAlert) {
                    Alert(
                        title: Text(LocaleKeys.EditEvent.error.rawValue.locale()),
                        message: Text(LocaleKeys.EditProfile.photoError.rawValue.locale()),
                        dismissButton: .default(Text(LocaleKeys.EditEvent.okButton.rawValue.locale())){
                            viewModel.showAlert = false
                        }
                    )
                }
            }else if !imageUrl.isEmpty && !data!.isEmpty{
                if let data = data{
                    if let selectedImage = UIImage(data: data){
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(width: UIScreen.main.bounds.width * 0.6,height:UIScreen.main.bounds.height * 0.25,alignment: .center)
                    }
                }
            }
            
            VStack{
                Form {
                    Section(header: Text(LocaleKeys.EditProfile.personalInfo.rawValue.locale())) {
                        TextField(LocaleKeys.EditProfile.name.rawValue.locale(), text: $name)
                        TextField(LocaleKeys.EditProfile.phone.rawValue.locale(), text: $phoneNumber)
                    }
                }
                Button {
                    do {
                        try viewModel.resetPassword(email: email)
                    } catch {
                        
                    }
                } label: {
                    ZStack{
                        Rectangle()
                            .fill(Color.red.opacity(0.4))
                            .frame(width: UIScreen.main.bounds.width * 0.8,height: 50)
                            .cornerRadius(10)
                        Text(LocaleKeys.EditProfile.reset.rawValue.locale())
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                    }
                    
                }
                .padding(.bottom)
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(title: Text(viewModel.alertTitle.locale()),
                          message: Text(viewModel.alertMessage.locale()),
                          dismissButton: .default(Text(LocaleKeys.EditProfile.okButton.rawValue.locale())){
                        viewModel.showAlert = false
                    })
                }
            }
            .customAlert(isPresented: $isSaving) {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.blue)
                    Text(LocaleKeys.EditProfile.loading.rawValue.locale())
                        .font(.headline)
                }
            } actions: {}
                .navigationBarTitle(LocaleKeys.EditProfile.title.rawValue.locale())
                .navigationBarItems(trailing: Button(action: {
                    Task{
                        isSaving = true
                        if data == nil{
                            do{
                                try await viewModel.updateUser(fullname: name, email: email, phoneNumber: phoneNumber, imageUrl: imageUrl)
                                isSaving = false
                            } catch{
                                
                            }
                        } else{
                            if let image = UIImage(data: data!) {
                                let imageUrl = try await viewModel.saveImage(image: image)
                                try await viewModel.updateUser(fullname: name, email: email, phoneNumber: phoneNumber,imageUrl:imageUrl)
                                isSaving = false
                            }
                        }
                    }
                }) {
                    Text(LocaleKeys.EditProfile.saveButton.rawValue.locale())
                        .foregroundColor(.red)
                })
                .navigationBarItems(leading: Button(action: {
                  
                   presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.title)
                        .foregroundStyle(.red)
                })
        }.onAppear{
            if !isFirstTime{
                Task{
                   try await viewModel.fetchUser()
                }
            }
        }
        }.navigationBarBackButtonHidden()
            .navigationViewStyle(StackNavigationViewStyle())

    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(name: "mete", email: "mete11@gmail.com", phoneNumber: "asdf", imageUrl: "String")
    }
}
