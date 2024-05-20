//
//  TempChildCameraView.swift
//  PicCharge
//
//  Created by Jongmin on 5/17/24.
//

import SwiftUI
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins

struct TempChildCameraView: View {
    
    @StateObject var camera = CameraModel()
    @State private var isFlashOn = false
    @State private var isFrontCamera = false

    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geo in
                    VStack {
                        CameraPreview(camera: camera)
                            .frame(width: geo.size.width, height: geo.size.width) // 정방형 프리뷰
                            .clipped()
                            .offset(y: 155)
                        Spacer()
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Button(action: {
                            // 자식 메인 화면 이동 넣기
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 17))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                        }
                        Spacer()
                    }
                    .padding()

                    Spacer()
           
                    HStack {
                        Button(action: {
                            isFlashOn.toggle()
                            camera.toggleFlash(isOn: isFlashOn)
                        }) {
                            Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .font(.system(size: 17))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isFrontCamera.toggle()
                            camera.switchCamera(isFront: isFrontCamera)
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 17))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                    
                    Button(action: {
                        camera.takePicture()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 64, height: 64)
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 76, height: 76)
                        }
                    }
                    .padding(.bottom, 95)
                }
            }
            .onAppear {
                camera.checkPermissions()
            }
            .navigationDestination(isPresented: $camera.showPreview) {
                TempChildSendCameraView(image: $camera.capturedImage)
            }
        }
    }
}



// CameraModel
class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isSessionRunning = false
    @Published var showPreview = false
    @Published var capturedImage: Image?
    @Published var isFlashOn = false
    
    var session: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var videoDeviceInput: AVCaptureDeviceInput!
    
    override init() {
        super.init()
        
        session = AVCaptureSession()
        session.beginConfiguration()
        
        if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                if session.canAddInput(videoDeviceInput) {
                    session.addInput(videoDeviceInput)
                }
                
                photoOutput = AVCapturePhotoOutput()
                if session.canAddOutput(photoOutput) {
                    session.addOutput(photoOutput)
                }
                
                session.commitConfiguration()
            } catch {
                print("Error setting up camera: \(error)")
            }
        }
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.startSession()
                    }
                }
            }
        default:
            break
        }
    }
    
    func startSession() {
        if !session.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func takePicture() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func toggleFlash(isOn: Bool) {
        isFlashOn = isOn
    }
    
    func switchCamera(isFront: Bool) {
        session.beginConfiguration()
        session.removeInput(videoDeviceInput)
        
        let newDevice = isFront ? getCamera(with: .front) : getCamera(with: .back)
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: newDevice!)
            session.addInput(videoDeviceInput)
        } catch {
            print("Error switching camera: \(error)")
        }
        
        session.commitConfiguration()
    }
    
    private func getCamera(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices
        return devices.first
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData),
              let rotatedImage = uiImage.fixedOrientation(),
              let ciImage = CIImage(image: rotatedImage) else { return }
        
        if let croppedCIImage = ciImage.croppedToSquare() {
            let context = CIContext()
            if let cgImage = context.createCGImage(croppedCIImage, from: croppedCIImage.extent) {
                self.capturedImage = Image(decorative: cgImage, scale: 1.0)
                self.showPreview = true
            }
        }
    }
}

extension UIImage {
    func fixedOrientation() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        if self.imageOrientation == .up {
            return self
        }

        var transform = CGAffineTransform.identity

        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
        case .up, .upMirrored:
            break
        @unknown default:
            return self
        }

        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            return self
        }

        guard let colorSpace = cgImage.colorSpace,
              let context = CGContext(
                data: nil,
                width: Int(self.size.width),
                height: Int(self.size.height),
                bitsPerComponent: cgImage.bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: cgImage.bitmapInfo.rawValue
              ) else {
            return nil
        }

        context.concatenate(transform)

        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }

        guard let newCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage)
    }
}

extension CIImage {
    func croppedToSquare() -> CIImage? {
        let contextSize = self.extent.size
        let length = min(contextSize.width, contextSize.height)
        let square = CGRect(x: (contextSize.width - length) / 2,
                            y: (contextSize.height - length) / 2,
                            width: length,
                            height: length)
        return self.cropped(to: square)
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        camera.session.addVideoPreviewLayer(to: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension AVCaptureSession {
    func addVideoPreviewLayer(to view: UIView) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: self)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
}



#Preview {
    TempChildCameraView()
}

