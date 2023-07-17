//
//  CustomTextField.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 15.07.2023.
//

import SwiftUI

struct CustomTextField: View {
    @State var imageName : String
    @State var placeholder : String
    @Binding var text : String
    var body: some View {
        HStack{
            Image(systemName: imageName)
                .foregroundColor(.black)
            TextField(placeholder.locale(), text: $text)
        }
        .padding(15)
        .foregroundColor(.black.opacity(0.8))
        .background(Capsule().fill(Color.gray.opacity(0.2)))
        .padding(.horizontal)
        .padding(.vertical)
    }}

