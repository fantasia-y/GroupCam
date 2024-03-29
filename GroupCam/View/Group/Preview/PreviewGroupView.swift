//
//  GroupPreviewView.swift
//  OneCam
//
//  Created by Gordon on 15.02.24.
//

import SwiftUI
import NukeUI

enum GroupPreviewType {
    case large
    case list
}

struct PreviewGroupView<Actions: View>: View {
    let image: UIImage?
    let name: String
    let imageCount: Int
    let group: Group?
    let size: GroupPreviewType
    let customActions: (() -> Actions)?
    
    init(image: UIImage?, name: String, size: GroupPreviewType = .large, customActions: (() -> Actions)?) {
        self.image = image
        self.name = name
        self.imageCount = 0
        self.group = nil
        self.size = size
        self.customActions = customActions
    }
    
    init(group: Group, size: GroupPreviewType = .large, customActions: (() -> Actions)?) {
        self.image = nil
        self.name = group.name
        self.imageCount = group.imageCount
        self.group = group
        self.size = size
        self.customActions = customActions
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                if let group {
                    LazyImage(url: URL(string: group.urls[size == .large ? FilterType.none.rawValue : FilterType.thumbnail.rawValue]!)) { state in
                        if let image = state.image {
                            image
                                .groupPreview(width: geometry.size.width, size: size)
                        } else if state.error != nil {
                            ZStack {
                                Color("buttonSecondary")
                                    .if(size == .large) { view in
                                        view.frame(width: geometry.size.width, height: geometry.size.width * 1.25)
                                    }
                                    .if(size == .list) { view in
                                        view.frame(height: 180)
                                    }
                                
                                ProgressView()
                            }
                        } else {
                            ZStack {
                                Color("buttonSecondary")
                                
                                Image(systemName: "questionmark")
                                    .foregroundStyle(Color("textPrimary"))
                                    .bold()
                            }
                        }
                    }
                } else if let image {
                    Image(uiImage: image)
                        .groupPreview(width: geometry.size.width, size: size)
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(name)
                            .bold()
                        
                        Text(imageCount != 1 ? "\(imageCount) group.preview.subtitle" : "group.preview.subtitle.single")
                            .font(.subheadline)
                            .foregroundStyle(Color("textSecondary"))
                    }
                    
                    Spacer()
                    
                    customActions?()
                }
                .padding()
                .background(.thinMaterial)
                .frame(maxWidth: .infinity)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .if(size == .list) { view in
            view.frame(height: 180)
        }
    }
}

extension PreviewGroupView where Actions == EmptyView {
    init(image: UIImage?, name: String, size: GroupPreviewType = .large) {
        self.image = image
        self.name = name
        self.imageCount = 0
        self.group = nil
        self.size = size
        self.customActions = nil
    }
    
    init(group: Group, size: GroupPreviewType = .large) {
        self.image = nil
        self.name = group.name
        self.imageCount = group.imageCount
        self.group = group
        self.size = size
        self.customActions = nil
    }
}

#Preview {
    PreviewGroupView(group: Group.Example)
}
