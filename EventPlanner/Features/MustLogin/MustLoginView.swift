//
//  MustLoginView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 17.08.2023.
//

import SwiftUI

struct MustLoginView: View {
    var body: some View {
        VStack{
            Image(IconItemString.Login.mustLogin.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.7)
            Text(LocaleKeys.Login.mustLogin.rawValue.locale())
                .font(.headline)
                .padding(.top)
        }
    }
}

struct MustLoginView_Previews: PreviewProvider {
    static var previews: some View {
        MustLoginView()
    }
}
