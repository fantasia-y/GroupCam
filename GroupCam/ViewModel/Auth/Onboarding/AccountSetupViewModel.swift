//
//  AccountSetupViewModel.swift
//  OneCam
//
//  Created by Gordon on 07.02.24.
//

import Foundation
import UIKit
import Combine
import _PhotosUI_SwiftUI
import Amplify
import GordonKirschAPI

class AccountSetupViewModel: ObservableObject {
    @Published var displayname = ""
    @Published var displaynameDebounced = ""
    @Published var image: UIImage?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $displayname
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] displayname in
                self?.displaynameDebounced = displayname
            })
            .store(in: &cancellables)
    }
}
