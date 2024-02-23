//
//  GroupSettingsViewModel.swift
//  OneCam
//
//  Created by Gordon on 24.01.24.
//

import Foundation
import GordonKirschAPI
import UIKit
import _PhotosUI_SwiftUI

class GroupSettingsViewModel: ObservableObject {
    @Published var showRemoveDialog = false
    @Published var showDeleteDialog = false
    @Published var showLeaveDialog = false
    @Published var showImageSelection = false
    @Published var showCamera = false
    @Published var showLibrary = false
    
    @Published var selectedUser: User?
    
    @Published var pickedItem: PhotosPickerItem?
    @Published var newImage: UIImage?
    @Published var newName: String = ""
    
    @Published var toast: Toast?
    
    @MainActor
    func removeSelectedUserFrom(group: Group) async -> User? {
        if let selectedUser {
            let result = await API.shared.delete(path: "/group/\(group.uuid)/user/\(selectedUser.id)", decode: [Group].self)
            
            if case .success(_) = result {
                let removedUser = selectedUser
                self.selectedUser = nil
                return removedUser
            } else {
                toast = Toast.from(response: result)
            }
        }
        
        return nil
    }
    
    @MainActor
    func save(group: Group) async -> Group? {
        var parameters = ["name": newName]
        
        let key = "\(UUID().uuidString.lowercased()).jpg"
        
        if let newImage, let _ = await ImageUtils.uploadImage(newImage, key: "group/\(key)") {
            parameters["imageName"] = key
        }
        
        let result = await API.shared.put(path: "/group/\(group.uuid)", decode: Group.self, parameters: parameters)
        
        if case .success(let data) = result {
            return data
        } else {
            toast = Toast.from(response: result)
        }
        
        return nil
    }
}
