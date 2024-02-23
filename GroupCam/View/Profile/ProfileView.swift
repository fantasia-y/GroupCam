//
//  ProfileView.swift
//  OneCam
//
//  Created by Gordon on 24.01.24.
//

import SwiftUI
import UIKit
import StoreKit

struct ProfileView: View {
    @Environment(\.requestReview) var requestReview
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authenticatedViewModel: AuthenticatedViewModel
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var colorSchemeSetting: ColorSchemeSetting
    @StateObject var viewModel = ProfileViewModel()
    
    var body: some View {
        SheetWrapper { path in
            if let currentUser = userData.currentUser {
                VStack {
                    Card {
                        HStack {
                            Avatar(user: currentUser)
                                .size(.medium)
                            
                            VStack(alignment: .leading) {
                                Text(currentUser.displayname ?? "Displayname")
                                    .bold()
                                
                                Text(currentUser.email ?? "E-Mail")
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                    
                    Button("button.edit") {
                        path.wrappedValue.append(currentUser)
                    }
                    .secondary()
                    .navigationDestination(for: User.self) { _ in
                        ProfileEditView(path: path)
                            .navigationTitle("profile.edit")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("profile.title")
                            .bold()
                            .padding(.top, 15)
                        
                        Card {
                            VStack(spacing: 0) {
                                CardListButton(text: "profile.design") {
                                    path.wrappedValue.append("darkmode")
                                }
                                
                                CardDivider()
                                
                                CardListButton(text: "profile.notifications") {
                                    path.wrappedValue.append("notifications")
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("profile.about")
                            .bold()
                            .padding(.top, 15)
                        
                        Card {
                            VStack(spacing: 0) {
                                CardListButton(text: "profile.rate") {
                                    requestReview()
                                }
                                
                                CardDivider()
                                
                                CardListButton(text: "profile.help") {
                                    path.wrappedValue.append("help")
                                }
                                
                                CardDivider()
                                
                                CardListButton(text: "profile.about-us") {
                                    path.wrappedValue.append("about")
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    AsyncButton("button.logout") {
                        await authenticatedViewModel.logout()
                        dismiss()
                    }
                    .destructive()
                    
                    Text("profile.version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                        .font(.subheadline)
                        .foregroundStyle(Color("textSecondary"))
                }
                .navigationTitle("profile.title")
                .navigationDestination(for: String.self) { path in
                    switch path {
                    case "darkmode":
                        DarkModeSettingsView()
                    case "notifications":
                        NotificationsSettingsView(user: currentUser)
                    case "help":
                        HelpView()
                    case "about":
                        AboutView()
                    default:
                        EmptyView()
                    }
                }
            }
        }
        .environmentObject(viewModel)
        .preferredColorScheme(colorScheme)
        .toastView(toast: $viewModel.toast, isSheet: true)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticatedViewModel())
        .environmentObject(UserData(currentUser: User.Example))
        .environmentObject(ColorSchemeSetting())
}
