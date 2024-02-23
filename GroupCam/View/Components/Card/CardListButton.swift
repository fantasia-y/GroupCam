//
//  CardListButton.swift
//  OneCam
//
//  Created by Gordon on 19.02.24.
//

import SwiftUI

struct CardListButton: View {
    let text: String
    var secondary: Bool = false
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(LocalizedStringKey(text))
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
        }
        .padding()
        .foregroundStyle(secondary ? Color("textSecondary") : Color("textPrimary"))
    }
}

#Preview {
    CardListButton(text: "Show all...") {
        
    }
}
