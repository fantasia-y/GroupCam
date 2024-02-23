//
//  EditGroupView.swift
//  OneCam
//
//  Created by Gordon on 19.02.24.
//

import SwiftUI
import CachedAsyncImage

struct GroupEditView: View {
    @EnvironmentObject var viewModel: GroupSettingsViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var group: Binding<Group>
    let path: Binding<NavigationPath>
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Button {
                    viewModel.showImageSelection = true
                } label: {
                    if let image = viewModel.newImage {
                        Image(uiImage: image)
                            .groupPreview(width: geometry.size.width, size: .list)
                    } else {
                        CachedAsyncImage(url: URL(string: group.wrappedValue.urls[FilterType.none.rawValue]!)!) { phase in
                            switch phase {
                            case .empty:
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("buttonSecondary"))
                                        .frame(height: 180)
                                    
                                    ProgressView()
                                }
                            case .success(let image):
                                image
                                    .groupPreview(width: geometry.size.width, size: .list)
                            case .failure:
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("buttonSecondary"))
                                        .frame(height: 180)
                                    
                                    Image(systemName: "questionmark")
                                        .foregroundStyle(Color("textPrimary"))
                                        .bold()
                                }
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                .onChange(of: viewModel.pickedItem) {
                    Task {
                        if let loaded = try? await viewModel.pickedItem?.loadTransferable(type: Data.self) {
                            viewModel.newImage = UIImage(data: loaded)!
                            viewModel.pickedItem = nil
                        }
                    }
                }
                .confirmationDialog("", isPresented: $viewModel.showImageSelection) {
                    Button("button.camera") {
                        viewModel.showCamera = true
                    }
                    
                    Button("button.gallery") {
                        viewModel.showLibrary = true
                    }
                    
                    if let _ = viewModel.newImage {
                        Button("button.undo", role: .destructive) {
                            viewModel.newImage = nil
                        }
                    }
                }
                .photosPicker(isPresented: $viewModel.showLibrary, selection: $viewModel.pickedItem)
                .fullScreenCover(isPresented: $viewModel.showCamera) {
                    ImagePicker(selectedImage: $viewModel.newImage)
                        .background() {
                            Color.black.ignoresSafeArea()
                        }
                }
                
                CustomTextField("name", text: $viewModel.newName)
                
                Spacer()
                
                AsyncButton("button.save") {
                    if let group = await viewModel.save(group: group.wrappedValue) {
                        path.wrappedValue.removeLast()
                        self.group.wrappedValue = group
                        homeViewModel.updateGroup(group)
                    }
                }
                .primary()
                .disabled(viewModel.newName.isEmpty)
            }
        }
        .padding()
        .onAppear() {
            viewModel.newName = group.wrappedValue.name
            viewModel.newImage = nil
        }
    }
}

#Preview {
    GroupEditView(group: .constant(Group.Example), path: .constant(NavigationPath()))
        .environmentObject(GroupSettingsViewModel())
        .environmentObject(HomeViewModel())
}
