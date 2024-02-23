//
//  AuthenticatedView.swift
//  CoLiving
//
//  Created by Gordon on 14.12.22.
//

import SwiftUI

struct AuthenticatedView<Unauthenticated: View, Content: View>: View {
    @StateObject var viewModel = AuthenticatedViewModel()
    
    let unauthenticated: Unauthenticated
    let content: Content
    
    init(@ViewBuilder unauthenticatedBuilder: () -> Unauthenticated, @ViewBuilder content contentBuilder: () -> Content) {
        self.unauthenticated = unauthenticatedBuilder()
        self.content = contentBuilder()
    }
    
    var body: some View {
        VStack {
            switch viewModel.authenticationState {
            case .unauthenticated, .authenticating:
                VStack {
                    unauthenticated
                        .sheet(isPresented: $viewModel.showLoginScreen) {
                            AuthView()
                                .environmentObject(viewModel)
                        }
                    
                    Spacer()
                    
                    Button("get-started") {
                        viewModel.showLoginScreen = true
                    }
                    .primary()
                }
                .padding()
            case .authenticated:
                VStack {
                    content
                        .environmentObject(viewModel)
                }
            }
        }
        .onAppear {
            viewModel.checkAccessToken()
        }
    }
}

#Preview {
    AuthenticatedView() {
        GetStartedView()
    } content: {
        Text("You are logged in")
    }
}
