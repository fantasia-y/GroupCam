//
//  GroupViewModel.swift
//  OneCam
//
//  Created by Gordon on 25.01.24.
//

import Foundation
import GordonKirschAPI
import UIKit
import Amplify

struct ImageWrapper: Identifiable {
    let id = UUID()
    let image: UIImage
}

@MainActor
class GroupViewModel: NSObject, ObservableObject {
    @Published var localImages: [LocalImage] = []
    @Published var images: [GroupImage] = []
    
    // selection variables
    var rectangles = Rectangles()
    @Published var selectRect: CGRect?
    @Published var selectedSubviews = Set<Int>()
    @Published var dragSelectedSubviews = Set<Int>()
    
    @Published var isEditing = false
    @Published var isSaving = false
    
    @Published var saveProgress = 0.0
    @Published var downloadedImages: [UIImage] = []
    @Published var showDownloadedImages = false
    @Published var hasFailedImages = false
    
    // sheet controls
    @Published var selectedImage: GroupImage?
    @Published var showShareView = false
    @Published var showSettings = false
    @Published var showCamera = false
    @Published var showCarousel = false
    @Published var showDeleteDialog = false
    
    @Published var toast: Toast?
    
    var currentPage = -1
    
    func getImages(_ group: Group) async {
        self.currentPage += 1
        
        let result = await API.shared.get(path: "/group/\(group.uuid)/images", decode: [GroupImage].self, parameters: ["page": currentPage.description])
        
        if case .success(let data) = result {
            self.images += data
        } else {
            toast = Toast.from(response: result)
        }
    }
    
    func getLocalImages(_ group: Group) {
        let request = LocalImage.fetchRequest()
        
        request.predicate = NSPredicate(format: "groupId == %@", group.groupId as CVarArg)
        
        do {
            localImages = try PersistenceController.shared.context.fetch(request)
            
            if localImages.filter({ $0.failed }).count > 0 {
                hasFailedImages = true
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func refreshImage(_ group: Group) async {
        self.currentPage = 0
        
        let result = await API.shared.get(path: "/group/\(group.uuid)/images", decode: [GroupImage].self, parameters: ["page": currentPage.description])
        
        if case .success(let data) = result {
            self.images = data
        } else {
            toast = Toast.from(response: result)
        }
    }
    
    @MainActor
    func uploadImage(_ image: UIImage, group: Group) async {
        let localImage = LocalImage(context: PersistenceController.shared.context)
        localImage.id = UUID()
        localImage.groupId = group.groupId
        localImage.imageData = image.jpegData(compressionQuality: 100)
        PersistenceController.shared.save()
        
        localImages.insert(localImage, at: 0)
        
        showCamera = false
        
        if let groupImage = await uploadLocalImage(localImage) {
            self.replaceLocalImage(localImage, with: groupImage)
        }
    }
    
    @MainActor
    func uploadLocalImage(_ localImage: LocalImage) async -> GroupImage? {
        localImage.failed = false
        self.updateLocalImage(localImage)
        
        let image = UIImage(data: localImage.imageData!)!
        let name = "\(localImage.id!.uuidString.lowercased()).jpeg"
        let key = "images/\(localImage.groupId!.uuidString.lowercased())/\(name)"
        
        if let _ = await ImageUtils.uploadImage(image, key: key) {
            let result = await API.shared.post(path: "/group/\(localImage.groupId!.uuidString.lowercased())/images", decode: GroupImage.self, parameters: ["name": name])
            if case .success(let data) = result {
                return data
            } else {
                toast = Toast.from(response: result)
            }
        } else {
            toast = Toast.ServerError
        }
        
        hasFailedImages = true
        localImage.failed = true
        self.updateLocalImage(localImage)
        
        return nil
    }
    
    @MainActor
    func retryLocalImages() async {
        hasFailedImages = false
        
        await withTaskGroup(of: (LocalImage, GroupImage?).self) { group in
            for localImage in localImages {
                group.addTask {
                    return (localImage, await self.uploadLocalImage(localImage))
                }
            }
            
            for await (localImage, groupImage) in group {
                if let groupImage {
                    self.replaceLocalImage(localImage, with: groupImage)
                }
            }
        }
    }
    
    func deleteImages(_ images: [GroupImage], group: Group) async -> Bool {
        let ids = images.map({ $0.id })
        self.images.removeAll(where: { ids.contains($0.id) })
        
        let result = await API.shared.delete(path: "/group/\(group.uuid)/images", parameters: ["images": ids])
        
        if case .success(_) = result {
            return true
        } else {
            toast = Toast.from(response: result)
            return false
        }
    }
    
    func deleteSelectedImages(_ group: Group) async {
        var images: [GroupImage] = []
        
        for index in selectedSubviews {
            images.append(self.images[index])
        }
        
        if await self.deleteImages(images, group: group) {
            selectedSubviews = Set<Int>()
        }
    }
    
    func updateLocalImage(_ localImage: LocalImage) {
        if let index = localImages.firstIndex(of: localImage) {
            localImages[index] = localImage
        }
        PersistenceController.shared.save()
    }
    
    func deleteLocalImage(_ localImage: LocalImage) {
        localImages.removeAll(where: { $0.id == localImage.id })
        PersistenceController.shared.context.delete(localImage)
    }
    
    private func replaceLocalImage(_ localImage: LocalImage, with image: GroupImage) {
        self.deleteLocalImage(localImage)
        images.insert(image, at: 0)
    }
    
    func saveSelectedImages() async {
        guard selectedSubviews.count > 0 else { return }
        
        // prep ui
        downloadedImages = []
        isSaving = true
        
        for index in selectedSubviews {
            let selectedImage = self.images[index]
            let url = selectedImage.urls[FilterType.none.rawValue]!
            
            saveProgress = Double(downloadedImages.count + 1) / Double(selectedSubviews.count)
            print("Downloading image: \(selectedImage.imageName!)")
            
            if let (data, _) = try? await URLSession.shared.data(from: URL(string: url)!) {
                downloadedImages.append(UIImage(data: data)!)
            }
        }
        
        // clean up
        isSaving = false
        saveProgress = 0.0
        showDownloadedImages = true
    }
}
