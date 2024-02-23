//
//  ProfileEditView.swift
//  OneCam
//
//  Created by Gordon on 19.02.24.
//

import SwiftUI
import UIKit

struct ProfileEditView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var viewModel: ProfileViewModel
    
    var path: Binding<NavigationPath>
    
    var body: some View {
        VStack(spacing: 20) {
            AvatarPicker(image: $viewModel.image, displayname: "", loadUserImage: true)
            
            CustomTextField("name", text: $viewModel.newDisplayname)
            
            Spacer()
            
            AsyncButton("button.save") {
                if let user = await viewModel.updateUser() {
                    path.wrappedValue.removeLast()
                    userData.currentUser = user
                }
            }
            .primary()
            .disabled(viewModel.newDisplayname.isEmpty)
        }
        .padding()
        .onAppear() {
            if let currentUser = userData.currentUser {
                viewModel.newDisplayname = currentUser.displayname ?? ""
                viewModel.image = nil
            }
        }
    }
}

#Preview {
    ProfileEditView(path: .constant(NavigationPath()))
        .environmentObject(UserData())
        .environmentObject(ProfileViewModel())
}
