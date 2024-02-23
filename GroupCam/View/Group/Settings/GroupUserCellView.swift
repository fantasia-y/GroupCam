//
//  GroupUserCellView.swift
//  OneCam
//
//  Created by Gordon on 19.02.24.
//

import SwiftUI

struct GroupUserCellView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var viewModel: GroupSettingsViewModel
    
    let group: Group
    let user: User
    
    var body: some View {
        HStack {
            Avatar(user: user)
            
            Text(user.displayname ?? "")
            
            Spacer()
            
            if group.isOwner(user) {
                Text("group.member.owner")
                    .foregroundStyle(Color("textSecondary"))
            }
            
            if let currentUser = userData.currentUser, currentUser.id != user.id, group.isOwner(currentUser) {
                Menu {
                    Button("button.remove", systemImage: "trash", role: .destructive) {
                        viewModel.showRemoveDialog = true
                        viewModel.selectedUser = user
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color("textSecondary"))
                }
            }
        }
        .padding(.all, 12)
    }
}

#Preview {
    GroupUserCellView(group: Group.Example, user: User.Example)
        .environmentObject(GroupSettingsViewModel())
        .environmentObject(UserData())
}
