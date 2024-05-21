//
//  TempChildCameraView.swift
//  PicCharge
//
//  Created by Jongmin on 5/17/24.
//

import SwiftUI
import AVFoundation

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
                    Button {
                        //MARK: - NavigationPath 사용 시 path에 .childMain 를 추가해야합니다.
                    } label: {
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
              let uiImage = UIImage(data: imageData) else {
            return
        }
        
        var finalImage = uiImage
        
        // 현재 입력 장치가 프론트 카메라인지 확인
        if let input = videoDeviceInput, input.device.position == .front {
            // 프론트 카메라의 경우 이미지를 180도 회전
            if let adjustedImage = uiImage.adjustedForFrontCamera() {
                finalImage = adjustedImage
            }
        }
        
        // 이미지를 정방형으로 자르기
        guard let croppedUIImage = finalImage.croppedToSquare() else {
            return
        }
        
        self.capturedImage = Image(uiImage: croppedUIImage)
        self.showPreview = true
    }
}

extension UIImage {
    // 프론트 카메라 이미지를 조정
    func adjustedForFrontCamera() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let orientedImage = UIImage(cgImage: cgImage, scale: self.scale, orientation: .leftMirrored)
        
        return orientedImage
    }
    
    // 이미지를 정방형으로 자르기
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

