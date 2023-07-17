//
//  SelectLanguageView.swift
//  EventPlanner
//
//  Created by Metehan Gürgentepe on 14.07.2023.
//

import SwiftUI

struct SelectLanguageView: View {
    var list = ["English", "Turkish"]
    
    var body: some View {
        List(list, id: \.self) { name in
            Text(name)
        }
    }
}


struct SelectLanguageView_Previews: PreviewProvider {
    static var previews: some View {
        SelectLanguageView()
    }
}
