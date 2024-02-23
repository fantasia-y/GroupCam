//
//  GroupSettingsUserListView.swift
//  OneCam
//
//  Created by Gordon on 19.02.24.
//

import SwiftUI

struct GroupSettingsUserListView: View {
    let group: Group
    let path: Binding<NavigationPath>
    var truncate = false
    
    var participantListNum: Int {
        min(3, group.participants.count)
    }
    
    var body: some View {
        Card {
            VStack(spacing: 0) {
                GroupUserCellView(group: group, user: group.owner)
                
                if truncate {
                    ForEach(group.participants[..<participantListNum].indices, id: \.self) { index in
                        CardDivider()
                        
                        GroupUserCellView(group: group, user: group.participants[index])
                    }
                } else {
                    ForEach(group.participants) { participant in
                        CardDivider()
                        
                        GroupUserCellView(group: group, user: participant)
                    }
                }
                
                
                if participantListNum < group.participants.count, truncate {
                    CardDivider()
                    
                    CardListButton(text: "Show all...", secondary: true) {
                        path.wrappedValue.append("users")
                    }
                }
            }
        }
    }
}

#Preview {
    GroupSettingsUserListView(group: Group.Example, path: .constant(NavigationPath()), truncate: true)
}
