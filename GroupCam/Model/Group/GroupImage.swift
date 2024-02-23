//
//  GroupImage.swift
//  OneCam
//
//  Created by Gordon on 25.01.24.
//

import Foundation

enum FilterType: String, Codable {
    case none = "original"
    case thumbnail = "thumbnail"
}

struct GroupImage: Codable, Identifiable, Hashable, ImageStorage {
    var id: Int
    var imageName: String?
    var urls: [String : String]
}

extension GroupImage {
    static let Example = GroupImage(id: 1, imageName: "test.jpg", urls: ["image": "https://onecam-dev133716-dev.s3.eu-central-1.amazonaws.com/public/images/df46e7ba-140d-4721-8b9e-a359dce5e78a/064c0123-b113-4008-b2e1-9dd60e2a7c41.jpg", "image_thumbnail": "https://onecam-dev133716-dev.s3.eu-central-1.amazonaws.com/cache/image_thumbnail/df46e7ba-140d-4721-8b9e-a359dce5e78a/064c0123-b113-4008-b2e1-9dd60e2a7c41.jpg"])
}
