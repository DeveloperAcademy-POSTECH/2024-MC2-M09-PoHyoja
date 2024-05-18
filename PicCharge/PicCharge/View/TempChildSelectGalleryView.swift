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
    
    var body: some View {
        // 일단 Temp파일로서, NavigationStack으로 사용
        NavigationStack {
            VStack {
                if let selectedImageData,
                   let uiImage = UIImage(data: selectedImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 360, height: 360)
                        .clipShape(RoundedRectangle(cornerRadius: 21))
                        .clipped()
                } else {
                    GalleryPicker(selectedImageData: $selectedImageData)
                        .frame(maxHeight: .infinity)
                    Spacer()
                }
                
                NavigationLink(destination: TempChildSendGalleryView(imageData: $selectedImageData)) {
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
