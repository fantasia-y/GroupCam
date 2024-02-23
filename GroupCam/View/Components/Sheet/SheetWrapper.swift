//
//  SheetWrapper.swift
//  OneCam
//
//  Created by Gordon on 15.02.24.
//

import SwiftUI

struct SheetWrapper<Content: View>: View {
    let title: String?
    let padding: Edge.Set?
    let sheetContent: (Binding<NavigationPath>) -> Content
    
    @State var path = NavigationPath()
    
    init(title: String? = nil, padding: Edge.Set? = .all, @ViewBuilder sheetContent: @escaping (Binding<NavigationPath>) -> Content) {
        self.sheetContent = sheetContent
        self.padding = padding
        self.title = title
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            sheetContent($path)
                .navigationTitle(LocalizedStringKey(title ?? ""))
                .toolbar() {
                    CloseButton()
                }
                .if(padding != nil) { view in
                    view.padding(padding!)
                }
        }
    }
}
