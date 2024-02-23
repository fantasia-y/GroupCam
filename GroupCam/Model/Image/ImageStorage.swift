//
//  ImageStorage.swift
//  OneCam
//
//  Created by Gordon on 07.02.24.
//

import Foundation

protocol ImageStorage {
    var imageName: String? { get set }
    var urls: [String: String] { get set }
}
