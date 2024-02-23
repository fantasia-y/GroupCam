//
//  ContentViewModel.swift
//  OneCam
//
//  Created by Gordon on 16.11.23.
//

import Foundation
import GordonKirschAPI
import UIKit
import Amplify

enum OnboardingState {
    case emailVerification
    case accountSetup
    case finished
}

class ContentViewModel: ObservableObject {
    @Published var onboardingState: OnboardingState = .finished
    @Published var isLoaded = false
    @Published var failedLoading = false
    @Published var userData = UserData()
    @Published var toast: Toast?
    
    var onboardingUser: User?
    
    @MainActor
    func loadUser() async -> Bool {
        self.failedLoading = false
        
        let result = await API.shared.get(path: "/user", decode: User.self)
        
        switch result {
        case .success(let user):
            self.onUserLoaded(user)
            self.isLoaded = true
            return true
        default:
            self.failedLoading = true
            return false
        }
    }
        
    func onUserLoaded(_ user: User) {
        userData.currentUser = user
        
        self.onboardingState = .finished
        if !user.emailVerified! {
            self.onboardingState = .emailVerification
        } else if !user.setupDone! {
            self.onboardingState = .accountSetup
        }
    }
    
    @MainActor
    func updateUser(_ displayname: String, _ image: UIImage?, completion: @escaping () -> ()) async {
        let key = "\(UUID().uuidString.lowercased()).jpg"
        var parameters = ["displayname": displayname]
        
        if let image, let _ = await ImageUtils.uploadImage(image, key: "user/\(key)") {
            parameters["image"] = key
        }
        
        let result = await API.shared.put(path: "/user/onboarding", decode: User.self, parameters: parameters)
        if case .success(let data) = result {
            self.onboardingUser = data
            completion()
        } else {
            toast = Toast.from(response: result)
        }
    }
    
    @MainActor
    func finishOnboarding() {
        if let onboardingUser {
            self.onUserLoaded(onboardingUser)
        }
    }
}
