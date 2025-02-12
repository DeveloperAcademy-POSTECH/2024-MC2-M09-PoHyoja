//
//  ImageCache.swift
//  PicCharge
//
//  Created by 남유성 on 2/12/25.
//

import UIKit

final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    init() {
        cache.totalCostLimit = 1024 * 1024 * 200 // 200MB 제한
        cache.countLimit = 200 // 최대 200개 이미지
    }
    
    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func insertImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
