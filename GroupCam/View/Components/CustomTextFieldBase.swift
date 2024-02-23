//
//  CustomTextfield.swift
//  CoLiving
//
//  Created by Gordon on 07.04.23.
//

import SwiftUI

struct CustomTextFieldBase<Field: View>: View {
    let placeholder: String
    let text: Binding<String>
    let invalid: Bool
    let fieldBuilder: (String, Binding<String>) -> Field
    
    init(_ placeholder: String, text: Binding<String>, invalid: Bool = false, fieldBuilder: @escaping (String, Binding<String>) -> Field) {
        self.placeholder = placeholder
        self.text = text
        self.invalid = invalid
        self.fieldBuilder = fieldBuilder
    }
    
    var body: some View {
        fieldBuilder(placeholder, text)
            .padding(12)
            .background(.background)
            .cornerRadius(10)
            .overlay {
                if invalid {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                        .fill(Color("textDestructive"))
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                        .fill(Color("buttonSecondary"))
                }
            }
    }
}

struct CustomTextField: View {
    let placeholder: String
    let text: Binding<String>
    let invalid: Bool
    
    init(_ placeholder: String, text: Binding<String>, invalid: Bool = false) {
        self.placeholder = placeholder
        self.text = text
        self.invalid = invalid
    }
    
    var body: some View {
        CustomTextFieldBase(placeholder, text: text, invalid: invalid) { placeholder, text in
            TextField("", text: text)
                .overlay(alignment: .leading,content: {
                    if text.wrappedValue.isEmpty {
                        Text(LocalizedStringKey(placeholder))
                            .foregroundStyle(Color("textSecondary"))
                    }
                })
        }
    }
}

struct CustomSecureField: View {
    let placeholder: String
    let text: Binding<String>
    let invalid: Bool
    
    init(_ placeholder: String, text: Binding<String>, invalid: Bool = false) {
        self.placeholder = placeholder
        self.text = text
        self.invalid = invalid
    }
    
    var body: some View {
        CustomTextFieldBase(placeholder, text: text, invalid: invalid) { placeholder, text in
            SecureField("", text: text)
                .overlay(alignment: .leading,content: {
                    if text.wrappedValue.isEmpty {
                        Text(LocalizedStringKey(placeholder))
                            .foregroundStyle(Color("textSecondary"))
                    }
                })
        }
    }
}

#Preview {
    CustomTextFieldBase("Placeholder", text: .constant(""), invalid: false) { placeholder, text in
        TextField(placeholder, text: text)
    }
    .padding()
}
