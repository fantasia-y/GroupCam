//
//  SessionView.swift
//  OneCam
//
//  Created by Gordon on 12.12.23.
//

import SwiftUI
import CachedAsyncImage

struct GroupView: View {
    @StateObject var viewModel = GroupViewModel()
    
    let group: Group
    
    var body: some View {
        if viewModel.showCamera {
            CameraView(showCamera: $viewModel.showCamera) { image in
                HStack {
                    AsyncButton("button.upload") {
                        await viewModel.uploadImage(image, group: group)
                    }
                    .primary()
                }
            }
            .navigationBarBackButtonHidden()
        } else {
            GroupGridView(group: group)
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    GroupView(group: Group.Example)
}
