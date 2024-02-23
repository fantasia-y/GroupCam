//
//  Card.swift
//  OneCam
//
//  Created by Gordon on 19.02.24.
//

import SwiftUI

struct Card<Content: View>: View {
    let content: () -> Content
    
    var body: some View {
        content()
            .background(Color("buttonSecondary"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    Card() {
        Text("Hello World")
    }
}
