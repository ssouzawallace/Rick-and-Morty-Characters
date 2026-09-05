//
//  ImageCache.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import UIKit

final class ImageCache {

    static let shared = ImageCache()

    private let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 200
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
        return cache
    }()

    private init() {}

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url.absoluteString as NSString)
    }

    func store(_ image: UIImage, for url: URL) {
        // Approximate decoded size in bytes; avoids re-encoding the image just to measure it.
        let cost = image.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        cache.setObject(image, forKey: url.absoluteString as NSString, cost: cost)
    }

    func removeImage(for url: URL) {
        cache.removeObject(forKey: url.absoluteString as NSString)
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}
