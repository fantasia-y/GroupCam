//
//  GroupNameView.swift
//  OneCam
//
//  Created by Gordon on 09.02.24.
//

import SwiftUI

struct CreateGroupNameView: View {
    @EnvironmentObject var viewModel: CreateGroupViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("group.create.name")
                .padding(.bottom, 25)
            
            CustomTextField("name", text: $viewModel.groupName)
            
            Spacer()
            
            AsyncButton("button.next") {
                hideKeyboard()
                
                withAnimation {
                    viewModel.page += 1
                }
            }
            .primary()
            .disabled(viewModel.groupName.isEmpty)
        }
        .padding(.horizontal)
    }
}

#Preview {
    CreateGroupNameView()
        .environmentObject(CreateGroupViewModel())
}
