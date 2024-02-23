//
//  CarouselView.swift
//  OneCam
//
//  Created by Gordon on 08.02.24.
//

import SwiftUI
import SwiftUIIntrospect

struct CarouselView<Tabs: View>: View {
    var page: Binding<Int>
    let tabs: () -> Tabs
    
    init(page: Binding<Int>, @ViewBuilder tabs: @escaping () -> Tabs) {
        self.page = page
        self.tabs = tabs
    }
    
    var body: some View {
        TabView(selection: page) {
            tabs()
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .introspect(.tabView(style: .page), on: .iOS(.v17)) { tabView in
            tabView.gestureRecognizers?.removeAll()
        }
    }
}

#Preview {
    CarouselView(page: .constant(1)) {
        
    }
}
