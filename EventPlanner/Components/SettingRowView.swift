//
//  SettingRowView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 9.07.2023.
//

import SwiftUI

struct SettingRowView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        
        HStack(spacing:12){
            Image(systemName: imageName)
                .imageScale(.small)
            //.aspectRatio(contentMode: .fit)
                .font(.title)
                .foregroundColor(tintColor)
            // .frame(width: geometry.size.width * 0.05)
            
            Text(title.locale())
                .font(.subheadline)
                .foregroundColor(.black)
        }
        
    }
}

struct SettingRowView_Previews: PreviewProvider {
    static var previews: some View {
        SettingRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
    }
}
