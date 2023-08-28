//
//  DropdownButton.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 26.07.2023.
//

import SwiftUI

struct DropdownButton: View {
    @Binding var selectedOption : String
    @State var selectedIcon : String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width * 0.4,height: UIScreen.main.bounds.height * 0.07)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke()
                )
            Menu{
                ForEach(CategoryModel.Categories, id: \.id){ item in
                    Button {
                        selectedOption = item.title.rawValue
                        selectedIcon = item.image.rawValue
                       // eventType = item.title.rawValue
                        print(selectedOption)
                    } label: {
                        HStack{
                            Text(item.title.rawValue.locale())
                            Image(item.image.rawValue)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20,height: 20)
                        }
                        
                    }
                }
            } label: {
                HStack{
                    Image(selectedIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20,height: 20)
                        .foregroundColor(.black)
                    Text(selectedOption.locale())
                }
                .padding(15)
                .foregroundColor(.black.opacity(0.8))
            }
           
        }.padding(.horizontal)
    }
}

/*struct DropdownButton_Previews: PreviewProvider {
    static var previews: some View {
        DropdownButton(selectedOption: "Select", selectedIcon: "arrow.down")
    }
}*/
