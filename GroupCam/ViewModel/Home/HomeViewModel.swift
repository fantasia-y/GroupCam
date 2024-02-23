//
//  HomeViewModel.swift
//  OneCam
//
//  Created by Gordon on 12.12.23.
//

import Foundation
import GordonKirschAPI
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var path = NavigationPath()
    
    @Published var showCreateGroup = false
    @Published var showCodeScanner = false
    @Published var showProfile = false
    @Published var showShareGroup = false
    @Published var showDeleteDialog = false
    @Published var showLeaveDialog = false
    
    @Published var initialLoad = true
    
    @Published var groups: [Group] = []
    @Published var toast: Toast?
    @Published var selectedGroup: Group?
    
    @MainActor
    func getGroups() async -> [Group] {
        let result = await API.shared.get(path: "/group", decode: [Group].self)
        
        if initialLoad { initialLoad.toggle() }
        if case .success(let data) = result {
            groups = data
            return data
        } else {
            toast = Toast.from(response: result)
        }
        
        return []
    }
    
    @MainActor
    func remove(user: User, fromGroup group: Group) -> Group? {
        if var group = groups.first(where: { $0.uuid == group.uuid }) {
            group.participants.removeAll(where: { $0.id == user.id })
            return group
        }
         return nil
    }
    
    @MainActor
    func leaveGroup(_ group: Group, user: User) async -> Bool {
        let result = await API.shared.delete(path: "/group/\(group.uuid)/user/\(user.id)", decode: [Group].self)
        
        if case .success(_) = result {
            groups.removeAll(where: { $0.id == group.id })
            
            if !path.isEmpty {
                path.removeLast()
            }
            
            return true
        } else {
            toast = Toast.from(response: result)
            
            return false
        }
    }
    
    @MainActor
    func deleteGroup(_ group: Group) async -> Bool {
        let result = await API.shared.delete(path: "/group/\(group.uuid)", decode: [Group].self)
        
        if case .success(_) = result {
            groups.removeAll(where: { $0.id == group.id })
            
            if !path.isEmpty {
                path.removeLast()
            }
            
            return true
        } else {
            toast = Toast.from(response: result)
            
            return false
        }
    }
    
    func updateGroup(_ group: Group) {
        if let index = groups.firstIndex(where: { $0.uuid == group.uuid }) {
            groups[index] = group
        }
    }
}
