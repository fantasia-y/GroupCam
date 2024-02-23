//
//  JoinGroupPreviewView.swift
//  OneCam
//
//  Created by Gordon on 15.02.24.
//

import SwiftUI

struct JoinGroupPreviewView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: JoinGroupViewModel
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        VStack(spacing: 20) {
            if let group = viewModel.group {
                Spacer()
                
                PreviewGroupView(group: group)
                
                Spacer()
                
                VStack {
                    AsyncButton("button.join") {
                        if await viewModel.joinGroup(group) {
                            dismiss()
                        }
                    }
                    .primary()
                    .disabled(!viewModel.isJoinable(forUser: userData.currentUser!))
                    
                    if !viewModel.isJoinable(forUser: userData.currentUser!) {
                        Text("group.join.info")
                            .font(.subheadline)
                            .foregroundStyle(Color("textSecondary"))
                    }
                }
            } else {
                ProgressView()
            }
        }
        .padding()
        .onAppear() {
            Task {
                await viewModel.getGroup()
            }
        }
    }
}

#Preview {
    JoinGroupPreviewView()
        .environmentObject(JoinGroupViewModel(group: Group.Example))
        .environmentObject(UserData(currentUser: User.Example))
}
