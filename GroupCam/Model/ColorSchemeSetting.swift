//
//  ColorSchemeSetting.swift
//  OneCam
//
//  Created by Gordon on 20.02.24.
//

import Foundation
import SwiftUI
import Combine

class ColorSchemeSetting: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var colorScheme: ColorScheme?
    
    init() {
        let selectedScheme = UserDefaults.standard.object(forKey: "design")
        self.colorScheme = ColorScheme.from(string: selectedScheme as? String)
        
        $colorScheme
            .dropFirst()
            .sink() {
                UserDefaults.standard.set($0?.stringValue, forKey: "design")
            }
            .store(in: &cancellables)
    }
}
