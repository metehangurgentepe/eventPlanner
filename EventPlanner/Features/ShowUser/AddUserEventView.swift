//
//  AddUserEventView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 25.07.2023.
//

import SwiftUI

struct AddUserEventView: View {
    @StateObject var viewModel = AddUserEventViewModel()
    var eventId : String
    var selectedUser = ""
    @State var text = ""
    @State var isEmptyText : Bool = true

    var body: some View {
        VStack{
            HStack {
                Image(systemName: IconItemString.Home.search.rawValue)
                    .foregroundColor(.black)
                
                TextField(LocaleKeys.Home.search.rawValue.locale(), text: $text)
                    .onChange(of: text) { newValue in
                        isEmptyText = text.isEmpty
                        viewModel.searchUser(query: text)
                    }
                isEmptyText ? Button{} label: {
                    Image(systemName: "")
                }
                : Button{
                    text = ""
                } label: {
                    Image(systemName: IconItemString.Home.close.rawValue)
                }
            }.modifier(customViewModifier(roundedCornes: 6, startColor: .white, endColor: .white, textColor: .black))
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom)
            List{
                ForEach(text.isEmpty ? viewModel.userList : viewModel.searchList,id: \.id){ user in
                    UserView(user: user)
                }.onDelete { indexSet in
                    for index in indexSet {
                        let user = viewModel.userList[index]
                        viewModel.removeUser(email: user.email, eventId: eventId)
                    }
                }
            }.onAppear{
                viewModel.getUsers(eventId: eventId)
            }.alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(LocaleKeys.AddUser.title.rawValue.locale()),
                    message: Text(viewModel.errorMessage.locale()),
                    dismissButton: .default(Text(LocaleKeys.Login.okButton.rawValue.locale()))
                )
            }
        }
    }
}

struct AddUserEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddUserEventView(eventId: "")
    }
}

struct UserView: View {
    var user: User
    var body: some View {
        HStack{
            AsyncImage(url: URL(string: user.imageUrl)) { image in
                image
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width:UIScreen.main.bounds.width * 0.1,height: UIScreen.main.bounds.height * 0.1)
                    .padding(.all)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .padding(.all)
            }.frame(width:UIScreen.main.bounds.width * 0.1,height: UIScreen.main.bounds.height * 0.1)
            Spacer()
            VStack{
                Text(user.fullname)
                    .font(.title3)
                    .bold()
                Text(user.email)
                    .font(.caption)
                    .frame(alignment: .leading)
            }
            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle(LocaleKeys.AddUser.title.rawValue.locale())
    }
}
