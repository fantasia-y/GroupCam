//
//  URLUtils.swift
//  OneCam
//
//  Created by Gordon on 23.11.23.
//

import Foundation
import GordonKirschAPI

class URLUtils {
    static func isOwnHost(_ url: URL) -> Bool {
        let own = URL(string: API.shared.getBaseUrl())!
        
        if let ownHost = own.host(), let otherHost = url.host() {
            return ownHost == otherHost
        }
        return false
    }
    
    static func generateShareUrl(forGroup group: Group) -> URL {
        var url = URL(string: API.shared.getBaseUrl())!
        url.append(path: "join")
        url.append(path: group.uuid)

        return url
    }
    
    static func handleIncomingUrl(_ url: URL) -> String? {
        guard url.scheme == "groupcam" else {
            return nil
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return nil
        }
        
        if let id = components.queryItems?.first(where: { $0.name == "id" })?.value {
            return id
        }
        
        return nil
    }
}
