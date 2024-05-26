//
//  PhotoForShare.swift
//  PicCharge
//
//  Created by 남유성 on 5/22/24.
//

import SwiftUI

struct PhotoForShare: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }
    
    init(imgData: Data, uploadDate: Date) {
        self.image = Image(uiImage: UIImage(data: imgData)!)
        self.caption = "\(uploadDate.toKR()) 자식사진"
    }

    public var image: Image
    public var caption: String
}
