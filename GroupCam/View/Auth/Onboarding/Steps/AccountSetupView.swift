//
//  AccountSetupView.swift
//  OneCam
//
//  Created by Gordon on 07.02.24.
//

import SwiftUI
import PhotosUI

struct AccountSetupView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject var viewModel = AccountSetupViewModel()
    
    let onFinish: () -> ()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("onboarding.setup.title")
                .font(.title)
                .bold()
                .padding(.top, 25)
            
            Text("onboarding.setup.subtitle")
                .padding(.bottom, 25)
            
            AvatarPicker(image: $viewModel.image, displayname: viewModel.displaynameDebounced)
            
            CustomTextField("name", text: $viewModel.displayname)
            
            Spacer()
            
            AsyncButton("button.next") {
                hideKeyboard()
                await contentViewModel.updateUser(viewModel.displayname, viewModel.image, completion: onFinish)
            }
            .primary()
            .disabled(viewModel.displayname.isEmpty)
        }
        .padding()
        .toastView(toast: $contentViewModel.toast)
    }
}

#Preview {
    AccountSetupView() {
        
    }
    .environmentObject(ContentViewModel())
}
