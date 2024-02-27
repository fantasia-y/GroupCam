//
//  Secrets.swift
//  GroupCam
//
//  Created by Gordon on 25.02.24.
//

import Foundation

import Foundation

struct Secrets {
    private static func secrets() -> [String: Any] {
        let fileName = "secrets"
        let path = Bundle.main.path(forResource: fileName, ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        return try! JSONSerialization.jsonObject(with: data) as! [String: Any]
    }

    static var baseURL: String {
        return secrets()["BASE_URL"] as! String
    }
    
    static var pusherInstance: String {
        return secrets()["PUSHER_INSTANCE_ID"] as! String
    }
    
    static var awsAccessKey: String {
        return secrets()["AWS_ACCESS_KEY_ID"] as! String
    }
    
    static var awsSecretKey: String {
        return secrets()["AWS_SECRET_ACCESS_KEY"] as! String
    }
    
    static var awsBucket: String {
        return secrets()["AWS_BUCKET"] as! String
    }
}
