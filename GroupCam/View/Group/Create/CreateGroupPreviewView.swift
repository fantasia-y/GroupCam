//
//  CreateGroupPreviewView.swift
//  OneCam
//
//  Created by Gordon on 09.02.24.
//

import SwiftUI

struct CreateGroupPreviewView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: CreateGroupViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("group.create.preview")
                .frame(maxWidth: .infinity)
            
            PreviewGroupView(image: viewModel.image, name: viewModel.groupName)
            
            Spacer()
            
            HStack {
                Button("button.back") {
                    withAnimation {
                        viewModel.page -= 1
                    }
                }
                .secondary()
                
                AsyncButton("button.create") {
                    if let group = await viewModel.publish() {
                        homeViewModel.groups.append(group)
                        dismiss()
                    }
                }
                .primary()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    CreateGroupPreviewView()
        .environmentObject(CreateGroupViewModel())
        .environmentObject(HomeViewModel())
}
