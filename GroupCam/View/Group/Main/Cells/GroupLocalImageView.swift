//
//  GroupLocalImageView.swift
//  OneCam
//
//  Created by Gordon on 30.01.24.
//

import SwiftUI

struct GroupLocalImageView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    
    let image: LocalImage
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(uiImage: ImageUtils.cropImage(UIImage(data: image.imageData!)!))
                .resizable()
                .scaledToFill()
                .contentShape(Rectangle())
                .clipped()
            
            if !image.failed {
                Image(systemName: "arrow.triangle.2.circlepath.icloud.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 20))
                    .shadow(radius: 4)
                    .padding(4)
            } else {
                Image(systemName: "exclamationmark.icloud.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 20))
                    .shadow(radius: 4)
                    .padding(4)
            }
        }
        .contextMenu {
            // if failed -> option to save
            
            Button("button.cancel", systemImage: "trash", role: .destructive) {
                viewModel.deleteLocalImage(image)
            }
        } preview: {
            Image(uiImage: UIImage(data: image.imageData!)!)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}
