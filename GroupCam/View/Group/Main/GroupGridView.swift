//
//  GroupGridView.swift
//  OneCam
//
//  Created by Gordon on 30.01.24.
//

import SwiftUI
import UIKit

class Rectangles {
    var content = [Int : CGRect]()
}

struct GroupGridView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State var group: Group
    
    let columns = [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(viewModel.localImages) { image in
                        GroupLocalImageView(image: image)
                    }
                    
                    ForEach(Array(viewModel.images.enumerated()), id: \.element) { index, image in
                        GroupImageView(image: image, group: group, isEditing: viewModel.isEditing, isSelected: isSelected(index))
                            .onAppear() {
                                if viewModel.images.count < group.imageCount, index == viewModel.images.count - 9 {
                                    Task {
                                        await viewModel.getImages(group)
                                    }
                                }
                            }
                            .background() {
                                GeometryReader { gp -> Color in
                                    viewModel.rectangles.content[index] = gp.frame(in: .named("container"))
                                    return Color.clear
                                }
                            }
                            .gesture(
                                TapGesture()
                                    .onEnded {
                                        if viewModel.selectedSubviews.contains(index) {
                                            viewModel.selectedSubviews.remove(index)
                                        } else {
                                            viewModel.selectedSubviews.insert(index)
                                        }
                                    }
                            )
                    }
                }
                .coordinateSpace(name: "container")
                .modifier(DragSelect(viewModel: viewModel))
            }
            
            if !viewModel.isEditing {
                Button {
                    viewModel.showCamera = true
                } label: {
                    Circle()
                        .stroke(.white, lineWidth: 6)
                        .frame(width: 70, height: 70)
                        .shadow(radius: 6)
                }
            }
            
            if viewModel.showCarousel {
                GroupCarouselView(group: group)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.animation(.easeIn),
                            removal: .opacity.animation(.easeOut)
                        )
                    )
            }
            
            if viewModel.showDownloadedImages {
                ActivityViewController(images: $viewModel.downloadedImages, showing: $viewModel.showDownloadedImages)
            }
        }
        .environmentObject(viewModel)
        .navigationTitle(group.name)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarBackground(.visible, for: .bottomBar)
        .toolbar() {
            GroupGridToolbar(viewModel: viewModel, group: group)
        }
        .sheet(isPresented: $viewModel.showSettings) {
            GroupSettingsView(group: $group)
        }
        .sheet(isPresented: $viewModel.showShareView) {
            ShareGroupView(group: group)
        }
        .confirmationDialog("group.grid.delete.multi.confirm \(viewModel.selectedSubviews.count)", isPresented: $viewModel.showDeleteDialog, titleVisibility: .visible) {
            Button("button.delete", role: .destructive) {
                Task {
                    await viewModel.deleteSelectedImages(group)
                }
            }
        }
        .refreshable() {
            Task {
                await viewModel.refreshImage(group)
            }
        }
        .onAppear() {
            Task {
                if viewModel.currentPage == -1 {
                    await viewModel.getImages(group)
                    viewModel.getLocalImages(group)
                }
            }
        }
        .overlay {
            GroupGridSaveOverlay()
        }
        .toastView(toast: $viewModel.toast)
    }
}
