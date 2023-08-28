//
//  GrayTextField.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 26.07.2023.
//

import SwiftUI

struct GrayTextField: View {
    @Binding var name : String
    @State var width : Double
    @State var height : Double
    @State var fieldWidth: Double
    @State var placeHolder:String
    @State var keyboardType : UIKeyboardType
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .circular)
                .frame(width: width, height: height)
                .clipped()
                .foregroundColor(.white.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black,lineWidth: 1)
                )
            TextField(placeHolder.locale(), text: $name)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal)
                .frame(width: UIScreen.main.bounds.width * fieldWidth)
                .keyboardType(keyboardType)
        }
    }
}

/*struct GrayTextField_Previews: PreviewProvider {
    static var previews: some View {
        GrayTextField(name: $name, width: 200, height: 40, fieldWidth: 0.5, placeHolder: "name")
    }
}*/
