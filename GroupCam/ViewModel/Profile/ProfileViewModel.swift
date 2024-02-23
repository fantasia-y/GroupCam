//
//  ProfileViewModel.swift
//  OneCam
//
//  Created by Gordon on 19.02.24.
//

import Foundation
import UIKit
import GordonKirschAPI

class ProfileViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var newDisplayname: String = ""
    
    @Published var toast: Toast?
    
    @MainActor
    func updateUser() async -> User? {
        let key = "\(UUID().uuidString.lowercased()).jpg"
        var parameters = ["displayname": newDisplayname]
        
        if let image, let _ = await ImageUtils.uploadImage(image, key: "user/\(key)") {
            parameters["imageName"] = key
        }
        
        let result = await API.shared.put(path: "/user", decode: User.self, parameters: parameters)
        if case .success(let data) = result {
            return data
        } else {
            toast = Toast.from(response: result)
        }
        
        return nil
    }
}
