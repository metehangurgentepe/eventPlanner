//
//  AddEventView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 9.07.2023.
//

import SwiftUI

struct AddEventView: View {
    @State private var eventName = ""
    @State private var eventType = ""
    @State private var description = ""
    @State private var price = ""
    @ObservedObject var eventVM = EventViewModel()
    @State var selectedOption : String = LocaleKeys.addEvent.select.rawValue
    @State var selectedIcon : String = IconItemString.Home.click.rawValue
    var isNavigatedToHomeView : Bool
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        NavigationView{
            VStack(spacing:30){
                Text(LocaleKeys.addEvent.title.rawValue.locale())
                    .font(.largeTitle)
                
                BorderTextField(name: $eventName, width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.07, placeHolder: LocaleKeys.addEvent.name.rawValue, iconName:  IconItemString.EventView.name.rawValue, keyboardType: .default)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.1)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 1) // Add the border here
                        )
                    TextField(LocaleKeys.addEvent.description.rawValue.locale(), text: $description, axis: .vertical)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .frame(width: UIScreen.main.bounds.width * 0.73)
                }
                
                DropdownButton(selectedOption: $selectedOption, selectedIcon: selectedIcon)
                
                NavigationLink(destination: AddEvent2View(eventName: eventName, eventType: selectedOption, description: description, isNavigatedToHomeView: isNavigatedToHomeView), label: {
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
                    .opacity(formIsValid ? 1.0 : 0.5)
                    .disabled(!formIsValid)
                }).disabled(!formIsValid)
            }
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.title)
                    .foregroundStyle(.red)
            })
        }.navigationBarBackButtonHidden()
    }
}

extension AddEventView: EventFormProtocol {
    var formIsValid: Bool {
        return !eventName.isEmpty && !description.isEmpty && !selectedOption.isEmpty && !(selectedOption == "addSelect")
    }
}



struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView( selectedOption: "Select Item", selectedIcon: "scope", isNavigatedToHomeView: true)
    }
}


