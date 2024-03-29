//
//  ImageUtils.swift
//  OneCam
//
//  Created by Gordon on 07.02.24.
//

import Foundation
import UIKit
import SwiftUI
import AWSClientRuntime
import ClientRuntime
import AWSS3
import os

enum CropOrientation {
    case portrait
    case landscape
}

class ImageUtils {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ImageUtils.self)
    )
    
    @MainActor
    static func uploadImage(_ image: UIImage, key: String) async -> String? {
        do {
            let config = try S3Client.S3ClientConfiguration(
                region: "eu-central-1",
                credentialsProvider: AWSClientRuntime.StaticCredentialsProvider(.init(
                    accessKey: Secrets.awsAccessKey,
                    secret: Secrets.awsSecretKey
                ))
            )
            
            let client = S3Client(config: config)
            
            if let data = image.jpegData(compressionQuality: 90) {
                let dataStream = ByteStream.data(data)
                
                let input = PutObjectInput(
                    body: dataStream,
                    bucket: Secrets.awsBucket,
                    contentType: "image/jpeg",
                    key: key
                )
                
                _ = try await client.putObject(input: input)
                
                return key
            }
        } catch {
            Self.logger.error("\(error.localizedDescription, privacy: .public)")
        }

        return nil
    }
    
    static func cropImage(_ image: UIImage) -> UIImage {
        let sideLength = min(
            image.size.width,
            image.size.height
        )

        let sourceSize = image.size
        let xOffset = (sourceSize.width - sideLength) / 2.0
        let yOffset = (sourceSize.height - sideLength) / 2.0

        // The cropRect is the rect of the image to keep,
        // in this case centered
        let cropRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: sideLength,
            height: sideLength
        ).integral

        // Center crop the image
        let sourceCGImage = image.cgImage!
        let croppedCGImage = sourceCGImage.cropping(
            to: cropRect
        )!

        return UIImage(
            cgImage: croppedCGImage,
            scale: image.imageRendererFormat.scale,
            orientation: image.imageOrientation
        )
    }
}

extension Image {
    func groupPreview(width: CGFloat, size: GroupPreviewType = .large) -> some View {
        self
            .resizable()
            .scaledToFill()
            .if(size == .large) { view in
                view.frame(width: width, height: width * 1.25)
            }
            .if(size == .list) { view in
                view.frame(height: 180)
            }
            .contentShape(Rectangle())
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
