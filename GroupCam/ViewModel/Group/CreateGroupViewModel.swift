//
//  CreateSessionViewModel.swift
//  OneCam
//
//  Created by Gordon on 16.11.23.
//

import Foundation
import SwiftUI
import GordonKirschAPI
import PhotosUI

class CreateGroupViewModel: ObservableObject {
    @Published var groupName: String = ""
    @Published var group: Group?
    @Published var page = 1
    
    @Published var image: UIImage?
    @Published var pickedItem: PhotosPickerItem?
    @Published var toast: Toast?
    
    @Published var showImageSelection = false
    @Published var showCamera = false
    @Published var showLibrary = false
    
    @MainActor
    func publish() async -> Group? {
        var parameters = ["name": groupName]
        
        let key = "\(UUID().uuidString.lowercased()).jpg"
        
        if let image, let _ = await ImageUtils.uploadImage(image, key: "group/\(key)") {
            parameters["imageName"] = key
        }
        
        let result = await API.shared.post(path: "/group", decode: Group.self, parameters: parameters)
        
        if case .success(let data) = result {
            return data
        } else {
            toast = Toast.from(response: result)
        }
        
        return nil
    }
}
