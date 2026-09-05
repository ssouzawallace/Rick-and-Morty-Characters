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
        cache.setObject(image, forKey: url.absoluteString as NSString, cost: cacheCost(for: image))
    }

    /// Approximates the decoded size of `image` in bytes. Measuring by re-encoding
    /// to JPEG would cost a compression pass on every store and returns nil for
    /// images that cannot be encoded.
    private func cacheCost(for image: UIImage) -> Int {
        if let cgImage = image.cgImage {
            return max(1, cgImage.bytesPerRow * cgImage.height)
        }

        let pixelWidth = Int(image.size.width * image.scale)
        let pixelHeight = Int(image.size.height * image.scale)
        return max(1, pixelWidth * pixelHeight * 4)
    }

    func removeImage(for url: URL) {
        cache.removeObject(forKey: url.absoluteString as NSString)
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}
