//
//  UserData.swift
//  OneCam
//
//  Created by Gordon on 12.12.23.
//

import Foundation

enum LoadingState {
    case loading
    case loaded
}

class UserData: ObservableObject {
    var currentUser: User?
    
    init(currentUser: User? = nil) {
        self.currentUser = currentUser
    }
}
