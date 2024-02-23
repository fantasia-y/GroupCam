//
//  FirstStepView.swift
//  OneCam
//
//  Created by Gordon on 08.02.24.
//

import SwiftUI

struct FirstStepView: View {
    @Binding var selection: Int
    let onFinish: () -> ()
    
    var body: some View {
        VStack {
            Text("Test")
            
            Spacer()
            
            HStack {
                Button("button.back") {
                    withAnimation {
                        selection -= 1
                    }
                }
                .secondary()
                
                Button("button.finish") {
                    onFinish()
                }
                .primary()
            }
        }
        .padding()
    }
}

#Preview {
    FirstStepView(selection: .constant(2)) {
        
    }
}
