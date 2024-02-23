//
//  ActivityViewController.swift
//  OneCam
//
//  Created by Gordon on 21.02.24.
//

import Foundation
import SwiftUI

class UIActivityViewControllerHost: UIViewController {
    var images: [UIImage] = []
    var completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        share()
    }
    
    func share() {
        let activityViewController = UIActivityViewController(activityItems: images, applicationActivities: nil)

        activityViewController.completionWithItemsHandler = completionWithItemsHandler
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        self.present(activityViewController, animated: true, completion: nil)
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Binding var showing: Bool
    
    func makeUIViewController(context: Context) -> UIActivityViewControllerHost {
            let result = UIActivityViewControllerHost()
            
            result.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
                self.showing = false
            }
            
            return result
        }
        
    func updateUIViewController(_ uiViewController: UIActivityViewControllerHost, context: Context) {
        uiViewController.images = images
    }
}
