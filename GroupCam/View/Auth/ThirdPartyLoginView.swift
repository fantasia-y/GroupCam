//
//  ThirdPartyLoginView.swift
//  CoLiving
//
//  Created by Gordon on 15.12.22.
//

import SwiftUI
import AuthenticationServices

struct ThirdPartyLoginView: View {
    @EnvironmentObject var viewModel: AuthenticatedViewModel
    
    var body: some View {
        VStack {
            SignInWithAppleButton() { request in
                viewModel.handleSignInWithAppleRequest(request)
            } onCompletion: { result in
                viewModel.handleSignInWithAppleCompletion(result)
            }
            .frame(height: 55)
            .cornerRadius(10)
            
            Button {
                viewModel.handleGoogleSignIn()
            } label: {
                HStack {
                    Image("google")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text("button.google")
                        .bold()
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color("buttonSecondary"))
            .foregroundStyle(Color("textPrimary"))
            .cornerRadius(10)
        }
    }
}

struct ThirdPartyLoginView_Previews: PreviewProvider {
    static var previews: some View {
        ThirdPartyLoginView()
            .environmentObject(AuthenticatedViewModel())
    }
}
