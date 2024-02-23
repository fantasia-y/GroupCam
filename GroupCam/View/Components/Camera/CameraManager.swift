//
//  CameraManager.swift
//  OneCam
//
//  Created by Gordon on 29.01.24.
//

import Foundation
import AVFoundation
import UIKit

class CameraDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let position: AVCaptureDevice.Position
    private let completion: (UIImage?) -> Void
     
    init(position: AVCaptureDevice.Position, completion: @escaping (UIImage?) -> Void) {
        self.position = position
        self.completion = completion
    }
     
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            print("CameraManager: Error while capturing photo: \(error)")
            completion(nil)
            return
        }

        if let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage(data: imageData) {
            let ciImage = CIImage(cgImage: capturedImage.cgImage!).oriented(forExifOrientation: 6)
            
            var cgImage: CGImage?
            if position == .front { // TODO lighting weird after flipping
                let flippedImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
                cgImage = CIContext.init().createCGImage(flippedImage, from: flippedImage.extent)
            } else {
                cgImage = CIContext.init().createCGImage(ciImage, from: ciImage.extent)
            }
            
            completion(.init(cgImage: cgImage!))
        } else {
            print("CameraManager: Image not fetched.")
        }
    }
}

class CameraManager: ObservableObject {
    enum Status {
        case configured
        case unconfigured
        case unauthorized
        case failed
    }
    
    @Published var image: UIImage?
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "dev.gordonkirsch.sessionQueue")
    private var inputDevice: AVCaptureDeviceInput?
    private var status: Status = .unconfigured
    private var position: AVCaptureDevice.Position = .back
    private var cameraDelegate: CameraDelegate?
    
    init() {
        configure()
    }
    
    deinit {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    private func configure() {
        checkPermissions()
        sessionQueue.async {
            self.configureCaptureSession()
            self.session.startRunning()
        }
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if !authorized {
                    self.status = .unauthorized
                }
                self.sessionQueue.resume()
            }
        case .restricted:
            print("Camera unauthorized")
            status = .unauthorized
        case .denied:
            print("Camera unauthorized")
            status = .unauthorized
        case .authorized:
            break
        @unknown default:
            print("Camera unauthorized")
            status = .unauthorized
        }
    }
    
    private func setupVideoInput() {
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
        guard let camera = device else {
            print("Failed to create input device")
            status = .failed
            return
        }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            inputDevice = cameraInput
            
            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            } else {
                print("Failed to add input device")
                status = .failed
                return
            }
        } catch {
            print(error)
            status = .failed
            return
        }
    }
    
    private func configureCaptureSession() {
        guard status == .unconfigured else {
            return
        }
        
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        setupVideoInput()
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.maxPhotoQualityPrioritization = .quality
        } else {
            print("Failed to add output")
            status = .failed
            return
        }
        
        status = .configured
    }
    
    func switchCamera() {
        position = position == .back ? .front : .back
        
        guard let inputDevice else { return }
        
        sessionQueue.async {
            self.session.removeInput(inputDevice)
            self.setupVideoInput()
        }
    }
    
    func cycleFlash() {
        switch flashMode {
        case .off:
            flashMode = .on
        case .on:
            flashMode = .auto
        case .auto:
            flashMode = .off
        @unknown default:
            fatalError()
        }
    }
    
    func captureImage() {
        sessionQueue.async {
            let photoSettings = AVCapturePhotoSettings()
            
            if let inputDevice = self.inputDevice, inputDevice.device.isFlashAvailable {
                photoSettings.flashMode = self.flashMode
            }

            photoSettings.photoQualityPrioritization = .quality
            
            self.cameraDelegate = CameraDelegate(position: self.position) { image in
                self.image = image
            }
            
            if let cameraDelegate = self.cameraDelegate {
                self.photoOutput.capturePhoto(with: photoSettings, delegate: cameraDelegate)
            }
        }
    }
}
