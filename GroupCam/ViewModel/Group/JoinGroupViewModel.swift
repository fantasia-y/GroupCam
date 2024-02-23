//
//  PreviewSessionViewModel.swift
//  OneCam
//
//  Created by Gordon on 11.12.23.
//

import Foundation
import GordonKirschAPI

class JoinGroupViewModel: ObservableObject {
    @Published var group: Group?
    @Published var groupId: String = ""
    @Published var page: Int = 1
    
    @Published var toast: Toast?
    
    init(group: Group? = nil) {
        self.group = group
    }
    
    @MainActor
    func getGroup() async {
        let result = await API.shared.get(path: "/group/\(groupId)", decode: Group.self)
        
        if case .success(let data) = result {
            group = data
        } else {
            toast = Toast.from(response: result)
        }
    }
    
    func joinGroup(_ group: Group) async -> Bool {
        let result = await API.shared.post(path: "/group/join", parameters: ["id": group.uuid])
        
        if case .success = result {
            return true
        } else {
            toast = Toast.from(response: result)
            return false
        }
    }
    
    func isJoinable(forUser user: User) -> Bool {
        if let session = group {
            return session.owner.id != user.id && !session.participants.contains(where: { participant in
                participant.id == user.id
            })
        }
        
        return false
    }
}
