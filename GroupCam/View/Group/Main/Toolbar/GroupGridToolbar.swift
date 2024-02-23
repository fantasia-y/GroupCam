//
//  GroupGridToolbar.swift
//  OneCam
//
//  Created by Gordon on 23.02.24.
//

import SwiftUI

struct GroupGridToolbar: ToolbarContent {
    @StateObject var viewModel: GroupViewModel
    let group: Group
    
    var body: some ToolbarContent {
        if !viewModel.showCarousel, !viewModel.isEditing {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if viewModel.hasFailedImages {
                        Button("button.retry-upload", systemImage: "arrow.clockwise") {
                            Task {
                                await viewModel.retryLocalImages()
                            }
                        }
                    }
                    
                    Button("button.select", systemImage: "checkmark.circle") {
                        viewModel.isEditing = true
                    }
                    
                    ShareLink(item: URLUtils.generateShareUrl(forGroup: group))

                    Button("share.qr", systemImage: "qrcode") {
                        viewModel.showShareView = true
                    }
                    
                    Button("button.settings", systemImage: "gear") {
                        viewModel.showSettings = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        
        if viewModel.isEditing {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button("button.cancel") {
                        viewModel.isEditing = false
                        viewModel.selectedSubviews = Set<Int>()
                    }
                }
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    Task {
                        await viewModel.saveSelectedImages()
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                
                Spacer()
                
                Button {
                    if viewModel.selectedSubviews.count > 0 {
                        viewModel.showDeleteDialog = true
                    }
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }
}
