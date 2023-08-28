//
//  SaveButton.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 26.07.2023.
//

import SwiftUI

struct CustomButton: View {
    @State var textColor: Color
    @State var buttonColor: Color
    @State var text: String
    @State var function: () -> Void
    
    
    var body: some View {
        Button(action: function, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(buttonColor)
                    .frame(width: UIScreen.main.bounds.width * 0.425,height: UIScreen.main.bounds.height * 0.07)
                Text(text.locale())
                    .foregroundColor(textColor)
            }
        })
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke()
        )
    }
}
