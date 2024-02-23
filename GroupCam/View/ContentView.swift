//
//  ContentView.swift
//  OneCam
//
//  Created by Gordon on 31.10.23.
//

import SwiftUI
import CodeScanner

struct ContentView: View {
    @EnvironmentObject var authenticatedViewModel: AuthenticatedViewModel
    @StateObject var viewModel = ContentViewModel()
    @StateObject var notificationSettings = LocalNotificationsSettings()
    
    var body: some View {
        if viewModel.isLoaded {
            switch viewModel.onboardingState {
            case .accountSetup:
                OnboardingView()
                    .environmentObject(viewModel)
            case .finished, .emailVerification:
                HomeView()
                    .environmentObject(viewModel.userData)
                    .environmentObject(notificationSettings)
            }
        } else {
            VStack {
                if !viewModel.failedLoading {
                    ProgressView()
                        .task {
                            if await viewModel.loadUser() {
                                notificationSettings.sync(fromUser: viewModel.userData.currentUser)
                            }
                        }
                } else {
                    VStack(spacing: 20) {
                        Text("login.error")
                            .font(.title)
                            .bold()
                            .padding(.top, 25)
                        
                        Text("login.error.text")
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        
                        VStack {
                            AsyncButton("button.try-again") {
                                if await viewModel.loadUser() {
                                    authenticatedViewModel.onAuthenticated()
                                    notificationSettings.sync(fromUser: viewModel.userData.currentUser)
                                }
                            }
                            .secondary()
                            
                            AsyncButton("button.logout") {
                                Task {
                                    await authenticatedViewModel.logout()
                                }
                            }
                            .destructive()
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticatedViewModel())
}
