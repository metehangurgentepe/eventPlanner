//
//  AddEventView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 9.07.2023.
//

import SwiftUI

struct AddEventView: View {
   // @State var isNavigatedToHomeView : Bool
    @Environment(\.presentationMode) var presentationMode
    @GestureState private var dragOffset = CGSize.zero
    @State var name : String = ""
    @State var desc : String = ""
    @State var type : String = ""
    @State var selectedOption : String = LocaleKeys.addEvent.select.rawValue
    @State var selectedIcon : String = IconItemString.Home.click.rawValue
    @Binding var path: NavigationPath
    @State private var eventData = AddEventData(name: "", desc: "", selectedOption: "")
    @State var testInt: Int


    
    var body: some View {
            VStack(spacing:30){
                Text(LocaleKeys.addEvent.title.rawValue.locale())
                    .font(.largeTitle)
                
                BorderTextField(name: $name, width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.07, placeHolder: LocaleKeys.addEvent.name.rawValue, iconName:  IconItemString.EventView.name.rawValue, keyboardType: .default)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.1)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 1) // Add the border here
                        )
                    TextField(LocaleKeys.addEvent.description.rawValue.locale(), text: $desc, axis: .vertical)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .frame(width: UIScreen.main.bounds.width * 0.73)
                        .lineLimit(4) // Limit the number of lines to 4
                        .truncationMode(.tail) 
                }
                
                DropdownButton(selectedOption: $selectedOption, selectedIcon: selectedIcon)
                Button{
                    path.append(AddEventData(name: name, desc: desc, selectedOption: selectedOption))
                }label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.black)
                            .frame(width: UIScreen.main.bounds.width * 0.4,height: UIScreen.main.bounds.height * 0.07)
                        HStack{
                            Text(LocaleKeys.addEvent.next.rawValue.locale())
                                .foregroundColor(.white)
                            Image(systemName: IconItemString.AddEvent.next.rawValue)
                                .foregroundColor(.white)
                        }
                    }
                }
                .opacity((!name.isEmpty && selectedOption != LocaleKeys.addEvent.select.rawValue) ? 1.0 : 0.5)
                .disabled(!(!name.isEmpty && selectedOption != LocaleKeys.addEvent.select.rawValue))
                
             /*   NavigationLink(value: AddEventData(name: name, desc: desc, selectedOption: selectedOption)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.black)
                            .frame(width: UIScreen.main.bounds.width * 0.4,height: UIScreen.main.bounds.height * 0.07)
                        HStack{
                            Text(LocaleKeys.addEvent.next.rawValue.locale())
                                .foregroundColor(.white)
                            Image(systemName: IconItemString.AddEvent.next.rawValue)
                                .foregroundColor(.white)
                        }
                    }
                }
                .opacity((!name.isEmpty && selectedOption != LocaleKeys.addEvent.select.rawValue) ? 1.0 : 0.5)
                .disabled(!(!name.isEmpty && selectedOption != LocaleKeys.addEvent.select.rawValue)) */
            }
            .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                if(value.startLocation.x < 60 &&
                   value.translation.width > 100) {
                    path.removeLast()
                   // self.presentationMode.wrappedValue.dismiss()
                }
            }))
            .navigationBarItems(leading: Button(action: {
               path.removeLast()
              // presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.title)
                    .foregroundStyle(.red)
            })
            .navigationBarBackButtonHidden()
    }
}





/*struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView(isNavigatedToHomeView: true, path: $path)
    }
} */


