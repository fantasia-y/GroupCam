//
//  CameraViewFinder.swift
//  OneCam
//
//  Created by Gordon on 29.01.24.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.backgroundColor = .black
        view.cameraPreviewLayer.session = session
        view.cameraPreviewLayer.videoGravity = .resizeAspectFill
        view.cameraPreviewLayer.connection?.videoOrientation = .portrait
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    class CameraPreviewView: UIView {
         override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
         }

         var cameraPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
         }
      }
}

struct CameraViewFinder: View {
    @EnvironmentObject var cameraManager: CameraManager
    
    @Binding var showCamera: Bool
    
    var flashIcon: String {
        switch cameraManager.flashMode {
        case .off:
            return "bolt.slash"
        case .on:
            return "bolt.fill"
        case .auto:
            return "bolt.badge.automatic.fill"
        @unknown default:
            fatalError()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea(.all)
                
                ZStack {
                    CameraPreview(session: cameraManager.session)
                        .ignoresSafeArea(.all)
                    
                    VStack {
                        HStack {
                            Button {
                                showCamera = false
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white)
                            }
                            .shadow(radius: 6)
                            
                            Spacer()
                            
                            if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
                                Button {
                                    cameraManager.cycleFlash()
                                } label: {
                                    Image(systemName: flashIcon)
                                        .font(.system(size: 24))
                                        .foregroundStyle(cameraManager.flashMode == .off ? .white : .yellow)
                                }
                                .shadow(radius: 6)
                            }
                        }
                        
                        Spacer()
                        
                        HStack {
                            Color.clear
                                .frame(height: 70)
                            
                            Button {
                                cameraManager.captureImage()
                            } label: {
                                Circle()
                                    .stroke(.white, lineWidth: 6)
                                    .frame(width: 70, height: 70)
                                    .shadow(radius: 6)
                            }
                            
                            Button {
                                cameraManager.switchCamera()
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath.camera")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .shadow(radius: 6)
                        }
                    }
                    .padding()
                }
                
                if let image = cameraManager.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
    }
}

#Preview {
    CameraViewFinder(showCamera: .constant(false))
}
