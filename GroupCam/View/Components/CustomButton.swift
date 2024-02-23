//
//  CustomButton.swift
//  OneCam
//
//  Created by Gordon on 08.02.24.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bold()
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("buttonPrimary"))
            .foregroundColor(.white)
            .cornerRadius(10)
            .opacity(isEnabled ? 1.0 : 0.8)
    }
}

struct PrimaryButtonModifier: ViewModifier {
    @Environment(\.isEnabled) var isEnabled
    
    func body(content: Content) -> some View {
        content
            .buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        return configuration
            .label
            .bold()
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("buttonSecondary"))
            .foregroundColor(Color("textPrimary"))
            .cornerRadius(10)
            .opacity(isEnabled ? 1.0 : 0.8)
    }
}

struct SecondaryButtonModifier: ViewModifier {
    @Environment(\.isEnabled) var isEnabled
    
    func body(content: Content) -> some View {
        content
            .buttonStyle(SecondaryButtonStyle(isEnabled: isEnabled))
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        return configuration
            .label
            .bold()
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("buttonSecondary"))
            .foregroundColor(Color("textDestructive"))
            .cornerRadius(10)
            .opacity(isEnabled ? 1.0 : 0.8)
    }
}

struct DestructiveButtonModifier: ViewModifier {
    @Environment(\.isEnabled) var isEnabled
    
    func body(content: Content) -> some View {
        content
            .buttonStyle(DestructiveButtonStyle(isEnabled: isEnabled))
    }
}

extension Button {
    func primary() -> some View {
        modifier(PrimaryButtonModifier())
    }
    
    func secondary() -> some View {
        modifier(SecondaryButtonModifier())
    }
    
    func destructive() -> some View {
        modifier(DestructiveButtonModifier())
    }
}

struct AsyncButton<Label: View>: View {
    var action: () async -> Void
    @ViewBuilder var label: () -> Label

    @State private var isPerformingTask = false

    func primary() -> some View {
        modifier(PrimaryButtonModifier())
    }
    
    func secondary() -> some View {
        modifier(SecondaryButtonModifier())
    }
    
    func destructive() -> some View {
        modifier(DestructiveButtonModifier())
    }
    
    var body: some View {
        Button(
            action: {
                isPerformingTask = true
            
                Task {
                    await action()
                    isPerformingTask = false
                }
            },
            label: {
                ZStack {
                    label().opacity(isPerformingTask ? 0 : 1)

                    if isPerformingTask {
                        ProgressView()
                    }
                }
            }
        )
        .disabled(isPerformingTask)
        .opacity(isPerformingTask ? 0.8 : 1)
    }
}

extension AsyncButton where Label == Text {
    init(_ titleKey: String, action: @escaping () async -> Void) {
        self.init(action: action) {
            Text(LocalizedStringKey(titleKey))
        }
    }
}

struct CloseButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .foregroundStyle(.black)
                .font(.system(size: 12))
                .bold()
                .padding(.all, 8)
                .background(Color("buttonSecondary"))
                .clipShape(Circle())
        }
    }
}

#Preview {
    VStack {
        Button("Normal") {
            print("Normal")
        }
        .primary()
        
        Button("Normal") {
            print("Normal")
        }
        .secondary()
        
        Button("Normal") {
            print("Normal")
        }
        .destructive()
        
        Button("Disabled") {
            print("Disabled")
        }
        .primary()
        .disabled(true)
        
        Button("Disabled") {
            print("Disabled")
        }
        .secondary()
        .disabled(true)
        
        Button("Disabled") {
            print("Disabled")
        }
        .destructive()
        .disabled(true)
        
        AsyncButton("Loading") {
            try? await Task.sleep(seconds: 5)
        }
        .primary()
        
        AsyncButton("Loading") {
            try? await Task.sleep(seconds: 5)
        }
        .secondary()
        
        AsyncButton("Loading") {
            try? await Task.sleep(seconds: 5)
        }
        .destructive()
    }
}
