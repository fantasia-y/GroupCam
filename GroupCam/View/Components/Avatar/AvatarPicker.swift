//
//  AvatarPicker.swift
//  OneCam
//
//  Created by Gordon on 07.02.24.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct AvatarPicker: View {
    @EnvironmentObject var userData: UserData
    
    @Binding var image: UIImage?
    var displayname: String?
    var loadUserImage = false
    
    @State var pickedItem: PhotosPickerItem?
    @State var showImageSelection = false
    @State var showCamera = false
    @State var showLibrary = false
    
    var body: some View {
        Button {
            showImageSelection = true
        } label: {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 128, height: 128)
                    .clipShape(Circle())
                    .clipped()
            } else {
                if loadUserImage {
                    Avatar(user: userData.currentUser)
                        .size(.large)
                } else if let displayname, !displayname.isEmpty {
                    Avatar(imageUrl: "https://ui-avatars.com/api/?name=\(displayname)&size=256")
                        .size(.large)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color("buttonSecondary"))
                            .frame(width: 128, height: 128)
                        
                        Image(systemName: "plus")
                            .foregroundStyle(Color("textPrimary"))
                            .bold()
                    }
                }
            }
        }
        .onChange(of: pickedItem) {
            Task {
                if let loaded = try? await pickedItem?.loadTransferable(type: Data.self) {
                    image = UIImage(data: loaded)!
                    pickedItem = nil
                }
            }
        }
        .confirmationDialog("", isPresented: $showImageSelection) {
            Button("button.camera") {
                showCamera = true
            }
            
            Button("button.gallery") {
                showLibrary = true
            }
            
            if let _ = image {
                Button("button.remove", role: .destructive) {
                    image = nil
                }
            }
        }
        .photosPicker(isPresented: $showLibrary, selection: $pickedItem)
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(selectedImage: $image)
                .background() {
                    Color.black.ignoresSafeArea()
                }
        }
    }
}
