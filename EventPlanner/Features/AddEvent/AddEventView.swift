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
    var body: some View {
        NavigationView{
            VStack{
                Text(LocaleKeys.addEvent.title.rawValue.locale())
                    .font(.largeTitle)
                
                
                
                CustomTextField(imageName: IconItemString.EventView.name.rawValue, placeholder: LocaleKeys.addEvent.name.rawValue, text: $eventName)
                
                
                CustomTextField(imageName: IconItemString.EventView.type.rawValue, placeholder: LocaleKeys.addEvent.type.rawValue, text: $eventType)
                
                CustomTextField(imageName: IconItemString.EventView.price.rawValue, placeholder: LocaleKeys.addEvent.price.rawValue, text: $price)
                
                
                
                NavigationLink(destination: AddEvent2View(eventName: eventName, eventType: eventType, price: price), label: {
                    HStack{
                        Text(LocaleKeys.addEvent.next.rawValue.locale())
                            .font(.title2)
                        Image(systemName:IconItemString.EventView.next.rawValue)
                    }
                    .padding(10)
                    .buttonStyle(.bordered)
                    .foregroundColor(.white)
                    .background(Color.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .opacity(formIsValid ? 1.0 : 0.5)
                    .disabled(!formIsValid)
                }).disabled(!formIsValid)
            }.navigationBarBackButtonHidden()
        }
    }
}

extension AddEventView: EventFormProtocol {
    var formIsValid: Bool {
        return !eventName.isEmpty && !eventType.isEmpty && isNumericString(price)
    }
}

// price is numeric?
func isNumericString(_ string: String) -> Bool {
    let numericRegex = "^[0-9]+$"
    let numericPredicate = NSPredicate(format: "SELF MATCHES %@", numericRegex)
    return numericPredicate.evaluate(with: string)
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
    }
}


