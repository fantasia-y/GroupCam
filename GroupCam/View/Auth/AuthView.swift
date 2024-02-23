//
//  LoginView.swift
//  CoLiving
//
//  Created by Gordon on 14.12.22.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var viewModel: AuthenticatedViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("welcome.title")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 25)
            
            Text("auth.subtitle")
                .multilineTextAlignment(.center)
                .padding(.bottom, 25)
            
            CustomTextField("email", text: $viewModel.email, invalid: !viewModel.authError.isEmpty)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            
            CustomSecureField("password", text: $viewModel.password, invalid: !viewModel.authError.isEmpty)
            
            if !viewModel.authError.isEmpty {
                Text("auth.error.credentials")
                    .foregroundStyle(Color("textDestructive"))
                    .font(.subheadline)
            }
            
            HStack {
                AsyncButton("button.login") {
                    await viewModel.login()
                }
                .secondary()
                
                AsyncButton("button.signup") {
                    await viewModel.register()
                }
                .primary()
            }
            
            HStack {
                VStack { Divider() }
                Text("divider.or")
                VStack { Divider() }
            }
            .padding()
            
            ThirdPartyLoginView()
            
            Spacer()
            
            Text("tos")
                .font(.footnote)
                .foregroundStyle(Color("textSecondary"))
        }
        .padding()
        .toastView(toast: $viewModel.toast, isSheet: true)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthenticatedViewModel())
}
