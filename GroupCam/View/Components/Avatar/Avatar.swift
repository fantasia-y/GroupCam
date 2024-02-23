//
//  Avatar.swift
//  OneCam
//
//  Created by Gordon on 24.01.24.
//

import SwiftUI
import CachedAsyncImage

enum AvatarSize: CGFloat {
    case small = 32
    case medium = 64
    case large = 128
    case extraLarge = 256
}

struct AvatarSizeKey: EnvironmentKey {
    static var defaultValue: AvatarSize = .small
}

extension EnvironmentValues {
  var avatarSize: AvatarSize {
    get { self[AvatarSizeKey.self] }
    set { self[AvatarSizeKey.self] = newValue }
  }
}

struct Avatar: View {
    @Environment(\.avatarSize) var size
    let imageUrl: String
    let image: Image?
    
    init(imageUrl: String) {
        self.imageUrl = imageUrl
        self.image = nil
    }
    
    init(user: User?, filter: FilterType = FilterType.thumbnail) {
        self.imageUrl = user?.urls[filter.rawValue] ?? ""
        self.image = nil
    }
    
    init(named: String) {
        self.imageUrl = ""
        self.image = Image(named)
    }
    
    var body: some View {
        if !imageUrl.isEmpty {
            CachedAsyncImage(url: URL(string: imageUrl)!) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .frame(width: size.rawValue, height: size.rawValue)
                        
                        ProgressView()
                            .frame(width: size.rawValue, height: size.rawValue)
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .frame(width: size.rawValue, height: size.rawValue)
                        .clipShape(.circle)
                case .failure:
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .frame(width: size.rawValue, height: size.rawValue)
                        
                        Image(systemName: "questionmark")
                            .foregroundStyle(.white)
                    }
                @unknown default:
                    EmptyView()
                }
            }
        } else if let image {
            image
                .resizable()
                .frame(width: size.rawValue, height: size.rawValue)
                .clipShape(.circle)
        } else {
            EmptyView()
        }
    }
}

extension Avatar {
  func size(_ size: AvatarSize) -> some View {
      environment(\.avatarSize, size)
  }
}

#Preview {
    VStack(spacing: 20) {
        HStack {
            Avatar(user: User.Example)
            
            Avatar(user: User.Example)
                .size(.medium)
            
            Avatar(user: User.Example)
                .size(.large)
        }
        
        HStack {
            Avatar(imageUrl: "unknown")
            
            Avatar(imageUrl: "unknown")
                .size(.medium)
            
            Avatar(imageUrl: "unknown")
                .size(.large)
        }
    }
}
