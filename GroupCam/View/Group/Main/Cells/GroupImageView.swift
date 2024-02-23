//
//  GridImageView.swift
//  OneCam
//
//  Created by Gordon on 25.01.24.
//

import SwiftUI
import CachedAsyncImage
import GordonKirschAPI

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
            CachedAsyncImage(url: URL(string: image.urls[FilterType.thumbnail.rawValue]!)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    Button {
                        viewModel.selectedImage = self.image
                        viewModel.showCarousel = true
                    } label: {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .contextMenu {
                                Button("button.delete", systemImage: "trash", role: .destructive) {
                                    showDeleteDialog = true
                                }
                            } preview: {
                                CachedAsyncImage(url: URL(string: self.image.urls[FilterType.none.rawValue]!)) { contextPhase in
                                    switch contextPhase {
                                    case .empty:
                                        ZStack {
                                            Rectangle()
                                                .fill(.gray)
                                                .frame(minWidth: 300, minHeight: 300)
                                            
                                            ProgressView()
                                        }
                                    case .success(let contextImage):
                                        contextImage
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    case .failure:
                                        ZStack {
                                            Rectangle()
                                                .fill(.gray)
                                            
                                            Image(systemName: "exclamationmark.triangle")
                                                .foregroundStyle(.white)
                                        }
                                    @unknown default:
                                        EmptyView()
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
                case .failure:
                    ZStack {
                        Rectangle()
                            .fill(.gray)
                            .frame(minWidth: 120, minHeight: 120)
                        
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.white)
                    }
                @unknown default:
                    EmptyView()
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
