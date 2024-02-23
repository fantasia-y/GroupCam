//
//  GroupLocalImage.swift
//  OneCam
//
//  Created by Gordon on 30.01.24.
//

import Foundation
import UIKit
import SwiftData

struct GroupLocalImage: Hashable, Identifiable {
    let id: UUID
    let group: Group
    let image: Data
    
    init(id: UUID, group: Group, image: Data) {
        self.id = id
        self.group = group
        self.image = image
    }
    
    var name: String {
        get { "\(id.uuidString.lowercased()).jpeg" }
    }
    
    var key: String {
        get { "images/\(group.uuid)/\(name)" }
    }
}
