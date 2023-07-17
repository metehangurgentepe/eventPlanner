//
//  ProfileView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 7.07.2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM : AuthViewModel
    var body: some View {
        if let user = authVM.currentUser {
            List{
                Section{
                    HStack{
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
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
                NavigationLink(destination: SelectLanguageView()) {
                    HStack{
                        SettingRowView(imageName: "globe", title: "Language", tintColor: Color(.systemGray))
                        Spacer()
                        Text("English")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                }
                
                
                NavigationLink(destination: EmptyView()) {
                    SettingRowView(imageName: "bookmark.circle.fill", title: "Saved Event", tintColor: Color(.systemGray))
                }
                
                NavigationLink(destination: EmptyView()) {
                    SettingRowView(imageName: "person.badge.key.fill", title: "Created Events", tintColor: Color(.systemGray))
                }
                
                
                
                Section(LocaleKeys.Profile.general.rawValue.locale()){
                    HStack{
                        SettingRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
                        Spacer()
                        Text("1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                }
                
                
                Section(LocaleKeys.Profile.account.rawValue.locale()){
                    Button{
                        Task{
                            authVM.signOut()
                        }
                    } label:{
                        SettingRowView(imageName: "arrow.left.circle.fill", title: LocaleKeys.Profile.signOut.rawValue, tintColor: .red)
                    }
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
