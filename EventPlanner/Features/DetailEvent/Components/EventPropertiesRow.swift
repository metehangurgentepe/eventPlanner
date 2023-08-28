//
//  EventPropertiesRow.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 16.07.2023.
//

import SwiftUI

struct EventPropertiesRow: View {
    var imageName : String
    var text : String
    
    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: imageName)
                .foregroundColor(.green)
                .frame(width: 20)
                .clipped()
            Text(text.locale())
            Spacer()
        }
        .font(.subheadline)
    }
}

struct EventPropertiesRow_Previews: PreviewProvider {
    static var previews: some View {
        EventPropertiesRow(imageName: "calendar", text: "14 Ekim")
    }
}
