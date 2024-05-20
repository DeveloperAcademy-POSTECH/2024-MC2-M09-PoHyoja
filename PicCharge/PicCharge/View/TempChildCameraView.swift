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
        // MARK: Temp파일로, NavigationStack을 사용
        NavigationStack {
            ZStack {
                GeometryReader { geo in
                    VStack {
                        CameraPreview(camera: camera)
                            .frame(width: geo.size.width, height: geo.size.width)
                            .clipped()
                            .offset(y: 155)
                    }
                }
                // 화면의 가로 끝부분까지 카메라가 보이도록 합니다.
                .edgesIgnoringSafeArea(.all)
                
                // 플래시 버튼, 카메라 전후면 전환 버튼, 카메라 셔터 버튼을 배치합니다.
                VStack {
                    Spacer()
                    
                    HStack {
                        Button {
                            isFlashOn.toggle()
                            camera.toggleFlash(isOn: isFlashOn)
                        } label: {
                            Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .font(.system(size: 17))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                        }
                        Spacer()
                        
                        Button {
                            isFrontCamera.toggle()
                            camera.switchCamera(isFront: isFrontCamera)
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 17))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                    Button {
                        camera.takePicture()
                    } label: {
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
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(action: {
                        //MARK: - 자식 메인화면으로 이동 시키기
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }
            .onAppear {
                camera.checkPermissions()
            }
            .navigationDestination(isPresented: $camera.showPreview) {
                //MARK: - NavigationPath 사용 시 path에 .childSendCamera 를 추가해야합니다.
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
        session.sessionPreset = .photo
        
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
              let croppedUIImage = rotatedImage.croppedToSquare() else {
            return
        }
        
        self.capturedImage = Image(uiImage: croppedUIImage)
        self.showPreview = true
    }
}

extension UIImage {
    func fixedOrientation() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        // 이미지 방향이 up이면 변경없이 반환
        if self.imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        // 기기의 기울기에 따라 가로 이미지 or 세로 이미지로 저장
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
        
        // 전면 카메라 사용 시 후면 카메라로 찍은 방향으로 반전 시켜줌
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
        
        // 이미지의 색상 공간, 크기, 비트맵 정보 등을 초기화
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
        
        // transform을 context에 담은 후
        context.concatenate(transform)
        
        // 위의 변환들을 적용하여 최종적으로 이미지(사진)를 그립니다.
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        guard let newCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage)
    }
    
    // 찍은 사진을 정방형으로 잘라줍니다.
    func croppedToSquare() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        let aspectRatio = width / height
        var rect: CGRect
        
        if aspectRatio > 1 {
            rect = CGRect(x: (width - height) / 2, y: 0, width: height, height: height)
        } else {
            rect = CGRect(x: 0, y: (height - width) / 2, width: width, height: width)
        }
        
        guard let croppedCGImage = cgImage.cropping(to: rect) else { return nil }
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}

// 카메라에서 보이는 부분
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        camera.session.addVideoPreviewLayer(to: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
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

