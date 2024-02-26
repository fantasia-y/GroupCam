//
//  GroupCarouselView.swift
//  OneCam
//
//  Created by Gordon on 30.01.24.
//

import SwiftUI
import CachedAsyncImage
import NukeUI

struct GroupCarouselView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @Namespace var imageDetail

    let group: Group
    
    @State var toolbarVisible = true
    @State var loadedImage: Image?
    @State var currentGroupImage: GroupImage?
    @State var showDeleteDialog = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea(.all)
                
                ScrollViewReader { reader in
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 8) {
                            ForEach(viewModel.images) { image in
                                LazyImage(url: URL(string: image.urls[FilterType.none.rawValue]!)) { state in
                                    if let stateImage = state.image {
                                        stateImage
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: geometry.size.width, height: geometry.size.height)
                                            .containerRelativeFrame(.horizontal)
                                            .id(image.id)
                                            .onAppear() {
                                                currentGroupImage = image
                                                loadedImage = stateImage
                                            }
                                    } else if state.error != nil {
                                        ZStack {
                                            Color("buttonSecondary")
                                                .frame(width: geometry.size.width, height: geometry.size.height)
                                            
                                            Image(systemName: "exclamationmark.triangle")
                                                .foregroundStyle(.white)
                                        }
                                    } else {
                                        ZStack {
                                            Color("buttonSecondary")
                                                .frame(width: geometry.size.width, height: geometry.size.height)
                                            
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.hidden)
                    .onAppear() {
                        if let selectedImage = viewModel.selectedImage {
                            reader.scrollTo(selectedImage.id)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationTitle("")
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.showCarousel = false
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.bold())
                        .foregroundColor(.white)
                        .frame(width: 16, height: 16)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 20) {
                    if let loadedImage {
                        ShareLink(item: loadedImage, preview: SharePreview("", image: loadedImage)) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                        }
                    }
                    
                    Button {
                        showDeleteDialog = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                    }
                    .confirmationDialog("group.grid.delete.confirm", isPresented: $showDeleteDialog, titleVisibility: .visible) {
                        Button("button.delete", role: .destructive) {
                            Task {
                                if let currentGroupImage {
                                    if await viewModel.deleteImages([currentGroupImage], group: group), viewModel.images.count == 0 {
                                        withAnimation() {
                                            viewModel.showCarousel = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
        .toastView(toast: $viewModel.toast)
    }
}

#Preview {
    GroupCarouselView(group: Group.Example)
        .environmentObject(GroupViewModel())
}
