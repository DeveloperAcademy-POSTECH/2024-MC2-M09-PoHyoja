//
//  ChildGalleryView.swift
//  PicCharge
//
//  Created by 남유성 on 5/16/24.
//

import SwiftUI

struct ChildSelectGalleryView: UIViewControllerRepresentable {
    @Environment(NavigationManager.self) var navigationManager
    @Binding var selectedImageData: Data?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.navigationBar.isTranslucent = false
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
         context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parentGalleryPicker: ChildSelectGalleryView

        init(_ parent: ChildSelectGalleryView) {
            self.parentGalleryPicker = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
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

#Preview {
    ChildSelectGalleryView(selectedImageData: .constant(nil))
        .environment(NavigationManager())
}


