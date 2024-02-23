//
//  Extensions.swift
//  OneCam
//
//  Created by Gordon on 16.11.23.
//

import Foundation
import JWTDecode
import UIKit
import SwiftUI

extension JWT {
    var uuid: UUID {
        return UUID(uuidString: self["uuid"].string!)!
    }
    
    var email: String {
        return self["username"].string!
    }
}

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 512_000_000, diskCapacity: 10_000_000_000)
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func toastView(toast: Binding<Toast?>, isSheet: Bool = false) -> some View {
        self.modifier(ToastModifier(toast: toast, isSheet: isSheet))
    }
}

extension ColorScheme {
    var stringValue: String? {
        switch self {
        case .dark:
            return "dark"
        case .light:
            return "light"
        default:
            return nil
        }
    }
    
    static func from(string: String?) -> Self? {
        switch string {
        case "dark":
            return .dark
        case "light":
            return .light
        default:
            return nil
        }
    }
}

struct GaugeProgressStyle: ProgressViewStyle {
    var strokeColor = Color.gray
    var strokeWidth = 6.0

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0

        return ZStack {
            Circle()
                .trim(from: 0, to: fractionCompleted)
                .stroke(strokeColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
