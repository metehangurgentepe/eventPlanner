//
//  ProfileView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 7.07.2023.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var authVM = AuthManager()
    @StateObject var viewModel = ProfileViewModel()
    let userDefaults = UserDefaults.standard
    // @Binding var themeMode : Bool = false
    var body: some View {
        if let user = authVM.currentUser {
            VStack{
                List{
                    NavigationLink(destination: EditProfileView(name: user.fullname, email: user.email, phoneNumber: user.phoneNumber,imageUrl: user.imageUrl)) {
                        Section{
                            HStack{
                                if user.imageUrl == ""{
                                    Group{
                                        Text(user.initials)
                                            .font(.title)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(width: 72, height: 72)
                                            .background(Color(.systemGray3)).clipShape(Circle())
                                    }
                                } else{
                                    Group{
                                        AsyncImage(url: URL(string:user.imageUrl ), content: { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: UIScreen.main.bounds.height * 0.10)
                                                .clipShape(Circle())
                                            
                                        }, placeholder: {
                                            Color.gray
                                                .frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.height * 0.15)
                                                .clipShape(Circle())
                                        })
                                    }
                                }
                                VStack(alignment: .leading, spacing: 4){
                                    Text(user.fullname)
                                        .font(.subheadline)
                                        .fontWeight (.semibold)
                                        .padding(.top, 4)
                                    Text( user.email)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                    Text( user.phoneNumber)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    
                    NavigationLink(destination: InvolvedEventView()) {
                        SettingRowView(imageName: "person.2", title: LocaleKeys.Profile.involved.rawValue, tintColor: Color(.systemGray))
                    }
                    
                    
                    NavigationLink(destination: CreatedEventView()) {
                        SettingRowView(imageName: IconItemString.Profile.create.rawValue, title: LocaleKeys.Profile.create.rawValue, tintColor: Color(.systemGray))
                    }
                    
                    //  Toggle("Dark Mode", isOn: $themeMode)
                    
                    NavigationLink(destination: DistanceForLocationView()) {
                        HStack{
                            SettingRowView(imageName: "location.north.circle.fill", title: LocaleKeys.Distance.title.rawValue, tintColor: Color(.systemGray))
                        }
                    }
                    
                    Section(LocaleKeys.Profile.general.rawValue.locale()){
                        HStack{
                            SettingRowView(imageName: IconItemString.Profile.settings.rawValue, title: LocaleKeys.Profile.version.rawValue, tintColor: Color(.systemGray))
                            Spacer()
                            Text(LocaleKeys.Profile.versionNumber.rawValue.locale())
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                    }
                    Section(LocaleKeys.Profile.account.rawValue.locale()){
                        Button{
                            Task{
                                viewModel.signOut()
                                viewModel.isSignOut = true // Set isSignOut to true when signing out
                            }
                        } label:{
                            SettingRowView(imageName: "arrow.left.circle.fill", title: LocaleKeys.Profile.signOut.rawValue, tintColor: .red)
                        }
                    }.background(
                        NavigationLink(
                            destination: LoginView(),
                            isActive: $viewModel.isSignOut,
                            label: {
                                EmptyView()
                            })
                    )
                    
                }
            }
            .navigationTitle(Text(LocaleKeys.Profile.title.rawValue.locale()))
            .navigationBarBackButtonHidden()
            .onAppear{
                Task{
                   await authVM.fetchUser()
                }
            }

        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
