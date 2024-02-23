//
//  GroupSettingsView.swift
//  OneCam
//
//  Created by Gordon on 24.01.24.
//

import SwiftUI

struct GroupSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var homeViewModel: HomeViewModel
    @StateObject var viewModel = GroupSettingsViewModel()
    
    var group: Binding<Group>
    
    var body: some View {
        SheetWrapper(title: "group.settings") { path in
            VStack(alignment: .leading) {
                PreviewGroupView(group: group.wrappedValue, size: .list) {
                    HStack {
                        if let currentUser = userData.currentUser, group.wrappedValue.isOwner(currentUser) {
                            Button {
                                path.wrappedValue.append("edit")
                            } label: {
                                Image(systemName: "pencil")
                                    .bold()
                                    .font(.system(size: 20))
                                    .foregroundStyle(.textPrimary)
                            }
                        }
                    }
                }

                Text("group.members")
                    .bold()
                    .padding(.top, 15)
                
                GroupSettingsUserListView(group: group.wrappedValue, path: path, truncate: true)
                    .confirmationDialog("group.remove.confirm", isPresented: $viewModel.showRemoveDialog, titleVisibility: .visible) {
                        Button("button.remove", role: .destructive) {
                            Task {
                                if let removedUser = await viewModel.removeSelectedUserFrom(group: group.wrappedValue) {
                                    if let group = homeViewModel.remove(user: removedUser, fromGroup: group.wrappedValue) {
                                        self.group.wrappedValue = group
                                    }
                                }
                            }
                        }
                    }
                    .navigationDestination(for: String.self) { view in
                        switch view {
                        case "users":
                            ScrollView {
                                GroupSettingsUserListView(group: group.wrappedValue, path: path)
                                    .padding()
                            }
                            .navigationTitle("group.members")
                            .navigationBarTitleDisplayMode(.inline)
                        case "edit":
                            GroupEditView(group: group, path: path)
                                .navigationTitle("group.edit")
                                .navigationBarTitleDisplayMode(.inline)
                        default:
                            EmptyView()
                        }
                    }
                
                Spacer()
                
                if let user = userData.currentUser {
                    Button("button.leave") {
                        viewModel.showLeaveDialog = true
                    }
                    .destructive()
                    .confirmationDialog("group.leave.confirm", isPresented: $viewModel.showLeaveDialog, titleVisibility: .visible) {
                        Button("button.leave", role: .destructive) {
                            Task {
                                if await homeViewModel.leaveGroup(group.wrappedValue, user: user) {
                                    dismiss()
                                }
                            }
                        }
                    }
                    
                    if group.wrappedValue.isOwner(user) {
                        Button("button.delete") {
                            viewModel.showDeleteDialog = true
                        }
                        .destructive()
                        .confirmationDialog("group.delete.confirm", isPresented: $viewModel.showDeleteDialog, titleVisibility: .visible) {
                            Button("button.delete", role: .destructive) {
                                Task {
                                    if await homeViewModel.deleteGroup(group.wrappedValue) {
                                        dismiss()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .toastView(toast: $viewModel.toast, isSheet: true)
        .toastView(toast: $homeViewModel.toast, isSheet: true)
        .environmentObject(viewModel)
        .environmentObject(userData)
    }
}

#Preview {
    GroupSettingsView(group: .constant(Group.Example))
        .environmentObject(UserData(currentUser: User.Example))
        .environmentObject(HomeViewModel())
}
