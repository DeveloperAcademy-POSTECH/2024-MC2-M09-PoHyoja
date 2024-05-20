//
//  TempChildSelectGalleryView.swift
//  PicCharge
//
//  Created by Woowon Kang on 5/18/24.
//

import SwiftUI
import PhotosUI

struct GalleryPickerView: UIViewControllerRepresentable {
    @Binding var selectedImageData: Data?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        picker.toolbar.isHidden = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parentGalleryPicker: GalleryPickerView

        init(_ parent: GalleryPickerView) {
            self.parentGalleryPicker = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            
            // MARK: 이미지 선택시 jpeg으로 압축
            if let image = info[.originalImage] as? UIImage {
                parentGalleryPicker.selectedImageData = image.jpegData(compressionQuality: 0.1)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct TempChildSelectGalleryView: View {
    // MARK: 아래 두 변수는 NavigationPath 적용 전 NavigationStack으로 이미지를 넘겨줄 때 사용되는 변수
    // MARK: 실제 작업 시 삭제 혹은 수정이 필요
    @State private var selectedImageData: Data?
    @State private var navigateToSendGalleryView = false
    
    var body: some View {
        // MARK: Temp파일로, NavigationStack을 사용
        NavigationStack {
            VStack {
                if let imageData = selectedImageData {
                    NavigationLink(destination: TempChildSendGalleryView(imageData: imageData), isActive: $navigateToSendGalleryView) {
                        EmptyView()
                    }
                    .onAppear {
                        navigateToSendGalleryView = true
                    }
                } else {
                    GalleryPickerView(selectedImageData: $selectedImageData)
                        .ignoresSafeArea()
                }
            }
            .navigationTitle("최근 사진")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    TempChildSelectGalleryView()
}
