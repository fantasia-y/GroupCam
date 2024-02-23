//
//  CreateSession.swift
//  OneCam
//
//  Created by Gordon on 16.11.23.
//

import SwiftUI

struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var homeViewModel: HomeViewModel
    @StateObject var viewModel = CreateGroupViewModel()
    
    var body: some View {
        SheetWrapper(padding: .vertical) { _ in
            VStack(spacing: 0) {
                Text("group.create.title")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 10)
                
                CarouselView(page: $viewModel.page) {
                    CreateGroupNameView()
                        .tag(1)
                    
                    CreateGroupImageView()
                        .tag(2)
                    
                    CreateGroupPreviewView()
                        .tag(3)
                }
            }
        }
        .environmentObject(viewModel)
        .toastView(toast: $viewModel.toast, isSheet: true)
    }
}

#Preview {
    CreateGroupView()
        .environmentObject(HomeViewModel())
}
