//
//  NotificationsSettingsView.swift
//  OneCam
//
//  Created by Gordon on 20.02.24.
//

import SwiftUI

struct NotificationsSettingsView: View {
    @EnvironmentObject var notificationSettings: LocalNotificationsSettings
    
    let user: User
    
    var body: some View {
        VStack(spacing: 25) {
            VStack(alignment: .leading) {
                Card {
                    Toggle("profile.notifications.new-images", isOn: $notificationSettings.newImage)
                        .padding()
                }
                
                Text("\(user.displayname ?? "Displayname") profile.notifications.new-images.info")
                    .font(.subheadline)
                    .foregroundStyle(Color("textSecondary"))
            }
            
            VStack(alignment: .leading) {
                Card {
                    Toggle("profile.notifications.new-members", isOn: $notificationSettings.newMember)
                        .padding()
                }
                
                Text("\(user.displayname ?? "Displayname") profile.notifications.new-members.info")
                    .font(.subheadline)
                    .foregroundStyle(Color("textSecondary"))
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("profile.notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NotificationsSettingsView(user: User.Example)
        .environmentObject(LocalNotificationsSettings())
}
