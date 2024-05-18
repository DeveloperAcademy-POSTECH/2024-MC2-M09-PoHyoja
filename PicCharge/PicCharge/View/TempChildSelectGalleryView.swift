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

    func makeUIViewController(context: Context) -> PHPickerViewController {
        let configuration = PHPickerConfiguration()
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = context.coordinator
                return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parentGalleryPicker: GalleryPicker

        init(_ parent: GalleryPicker) {
            self.parentGalleryPicker = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        if let uiImage = image as? UIImage {
                            self.parentGalleryPicker.selectedImageData = uiImage.jpegData(compressionQuality: 1.0)
                        }
                    }
                }
            }
        }
    }
}

struct TempChildSelectGalleryView: View {
    //@State private var selectedItem: PhotosPickerItem? = nil
    //@State private var selectedImage: Data? = nil
    @State private var selectedImageData: Data? = nil
    //@State private var isShowingSendGalleryView = false
    
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
                    //EmptyView()
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
