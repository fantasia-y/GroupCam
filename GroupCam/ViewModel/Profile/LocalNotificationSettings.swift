//
//  LocalNotificationSettings.swift
//  OneCam
//
//  Created by Gordon on 21.02.24.
//

import Foundation
import Combine
import GordonKirschAPI

class LocalNotificationsSettings: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var newImage: Bool = true
    @Published var newMember: Bool = true
    
    init() {
        handleSetting($newImage, backendName: "NewImageNotifications")
        handleSetting($newMember, backendName: "NewMemberNotifications")
    }
    
    func sync(fromUser user: User?) {
        if let user, let notificationSettings = user.notificationSettings {
            newImage = notificationSettings.newImageNotifications
            newMember = notificationSettings.newMemberNotifications
        }
    }
    
    private func handleSetting(_ setting: Published<Bool>.Publisher, backendName: String) {
        setting
            .dropFirst(2)
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { value in
                Task {
                    let _ = await API.shared.post(path: "/user/notifications", parameters: [backendName: value])
                }
            }
            .store(in: &cancellables)
    }
}
