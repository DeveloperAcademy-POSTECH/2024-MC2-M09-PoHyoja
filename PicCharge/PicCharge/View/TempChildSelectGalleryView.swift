//
//  TempChildSelectGalleryView.swift
//  PicCharge
//
//  Created by Woowon Kang on 5/18/24.
//

import SwiftUI
import PhotosUI

struct GalleryPicker: UIViewControllerRepresentable {
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
        var parentGalleryPicker: GalleryPicker

        init(_ parent: GalleryPicker) {
            self.parentGalleryPicker = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                parentGalleryPicker.selectedImageData = image.jpegData(compressionQuality: 1.0)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct TempChildSelectGalleryView: View {
    @State private var selectedImageData: Data? = nil
    @State private var navigateToSendGalleryView = false
    
    var body: some View {
        // 일단 Temp파일로서, NavigationStack으로 사용
        NavigationStack { 
            VStack {
                if let selectedImageData,
                   let uiImage = UIImage(data: selectedImageData) {                    NavigationLink(destination: TempChildSendGalleryView(imageData: $selectedImageData), isActive: $navigateToSendGalleryView) {
                        EmptyView()
                    }
                    .hidden()
                    .onAppear() {
                        navigateToSendGalleryView = true
                    }
                } else {
                    GalleryPicker(selectedImageData: $selectedImageData)
                        .frame(maxHeight: .infinity)
                    Spacer()
                }
            }
            .navigationTitle("최근 사진")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    TempChildSelectGalleryView()
}
