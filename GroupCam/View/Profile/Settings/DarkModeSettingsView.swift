//
//  DarkModeSettingsView.swift
//  OneCam
//
//  Created by Gordon on 20.02.24.
//

import SwiftUI

struct DarkModeSettingsView: View {
    @EnvironmentObject var colorSchemeSetting: ColorSchemeSetting
    
    var values: [ColorScheme] = ColorScheme.allCases
    
    var body: some View {
        VStack {
            Card {
                VStack(spacing: 0) {
                    Button {
                        colorSchemeSetting.colorScheme = nil
                    } label: {
                        Text("profile.design.system")
                        
                        Spacer()
                        
                        if colorSchemeSetting.colorScheme == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                    .padding()
                    .foregroundStyle(Color("textPrimary"))
                    
                    CardDivider()
                    
                    Button {
                        colorSchemeSetting.colorScheme = .light
                    } label: {
                        Text("profile.design.light")

                        Spacer()
                        
                        if colorSchemeSetting.colorScheme == .light {
                            Image(systemName: "checkmark")
                        }
                    }
                    .padding()
                    .foregroundStyle(Color("textPrimary"))
                    
                    CardDivider()
                    
                    Button {
                        colorSchemeSetting.colorScheme = .dark
                    } label: {
                        Text("profile.design.dark")
                        
                        Spacer()
                        
                        if colorSchemeSetting.colorScheme == .dark {
                            Image(systemName: "checkmark")
                        }
                    }
                    .padding()
                    .foregroundStyle(Color("textPrimary"))
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("profile.design")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(colorSchemeSetting.colorScheme)
    }
}

#Preview {
    DarkModeSettingsView()
        .environmentObject(ColorSchemeSetting())
}
