//
//  NotificationSettings.swift
//  OneCam
//
//  Created by Gordon on 21.02.24.
//

import Foundation

struct NotificationSettings: Codable, Identifiable, Hashable {
    let id: Int
    let newImageNotifications: Bool
    let newMemberNotifications: Bool
}

extension NotificationSettings {
    static let Example = NotificationSettings(id: 1, newImageNotifications: true, newMemberNotifications: true)
}
