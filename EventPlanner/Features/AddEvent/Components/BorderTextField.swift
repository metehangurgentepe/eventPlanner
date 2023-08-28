//
//  BorderTextField.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 18.08.2023.
//

import SwiftUI

struct BorderTextField: View {
    @Binding var name : String
    @State var width : Double
    @State var height : Double
    @State var placeHolder:String
    @State var iconName: String
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
                HStack{
                    TextField(placeHolder.locale(), text: $name)
                        .font(.headline)
                        .foregroundColor(.black)
                        .keyboardType(keyboardType)
                    Image(systemName: iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: UIScreen.main.bounds.height * 0.03)
                }
                .padding(.horizontal)
                .frame(width: width)
            }
    }
}

