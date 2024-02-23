//
//  User.swift
//  CoLiving
//
//  Created by Gordon on 31.03.23.
//

import Foundation

struct User: Codable, Identifiable, Hashable, ImageStorage {
    let id: Int
    let email: String?
    let displayname: String?
    let emailVerified: Bool?
    let setupDone: Bool?
    var imageName: String?
    var urls: [String : String]
    let notificationSettings: NotificationSettings?
}

extension User {
    static let Example = User(
        id: 1,
        email: "me@gordonkirsch.dev",
        displayname: "Gordon",
        emailVerified: true,
        setupDone: true,
        urls: ["original": "https://onecam-dev133716-dev.s3.eu-central-1.amazonaws.com/public/user/cd709dc1-6603-400c-af8c-9c621b162a82.jpg", "thumbnail": "https://onecam-dev133716-dev.s3.eu-central-1.amazonaws.com/cache/user_thumbnail/cd709dc1-6603-400c-af8c-9c621b162a82.jpg"],
        notificationSettings: NotificationSettings.Example
    )
}
