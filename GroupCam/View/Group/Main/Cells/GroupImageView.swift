//
//  GridImageView.swift
//  OneCam
//
//  Created by Gordon on 25.01.24.
//

import SwiftUI
import GordonKirschAPI
import NukeUI

struct GroupImageView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @Namespace var namespace
    
    let image: GroupImage
    let group: Group
    var isEditing: Bool
    var isSelected: Bool
    
    @State var showDeleteDialog = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LazyImage(url: URL(string: image.urls[FilterType.thumbnail.rawValue]!)) { state in
                if let image = state.image {
                    Button {
                        viewModel.selectedImage = self.image
                        viewModel.showCarousel = true
                    } label: {
                        image
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .contextMenu {
                                Button("button.delete", systemImage: "trash", role: .destructive) {
                                    showDeleteDialog = true
                                }
                            } preview: {
                                LazyImage(url: URL(string: self.image.urls[FilterType.none.rawValue]!)) { contextState in
                                    if let contextImage = contextState.image {
                                        contextImage
                                            .resizable()
                                            .scaledToFit()
                                    } else if contextState.error != nil {
                                        ZStack {
                                            Color("buttonSecondary")
                                            
                                            Image(systemName: "exclamationmark.triangle")
                                                .foregroundStyle(.white)
                                        }
                                    } else {
                                        ZStack {
                                            Color("buttonSecondary")
                                                .frame(minWidth: 300, minHeight: 300)
                                            
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                    }
                    .disabled(isEditing)
                    .overlay {
                        if isEditing, isSelected {
                            Color.white
                                .opacity(0.2)
                        }
                    }
                } else if state.error != nil {
                    ZStack {
                        Color.gray
                        
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.white)
                    }
                } else {
                    ZStack {
                        Color.gray
                        
                        ProgressView()
                    }
                }
            }
            
            if isEditing {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(.white)
                    .font(.system(size: 20))
                    .shadow(radius: 4)
                    .padding(4)
            }
        }
        .confirmationDialog("group.grid.delete.confirm", isPresented: $showDeleteDialog, titleVisibility: .visible) {
            Button("button.delete", role: .destructive) {
                Task {
                    await viewModel.deleteImages([image], group: group)
                }
            }
        }
    }
}

#Preview {
    GroupImageView(image: GroupImage.Example, group: Group.Example, isEditing: false, isSelected: false)
        .environmentObject(GroupViewModel())
        .environmentObject(UserData())
}
