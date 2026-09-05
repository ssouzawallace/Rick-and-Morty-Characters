//
//  Rick_and_Morty_ImageCacheTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Wallace Souza Silva
//

import XCTest
import UIKit
@testable import Rick_and_Morty_Characters

final class Rick_and_Morty_ImageCacheTests: XCTestCase {

    var sut: ImageCache!

    override func setUp() {
        super.setUp()
        sut = ImageCache.shared
        sut.clearCache()
    }

    override func tearDown() {
        sut.clearCache()
        super.tearDown()
    }

    func testStoreAndRetrieveImage() {
        let url = URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!
        let image = UIImage(systemName: "star")!

        sut.store(image, for: url)

        XCTAssertNotNil(sut.image(for: url), "Stored image should be retrievable from cache")
    }

    func testMissingImageReturnsNil() {
        let url = URL(string: "https://rickandmortyapi.com/api/character/avatar/999.jpeg")!

        XCTAssertNil(sut.image(for: url), "Cache should return nil for a URL that was never stored")
    }

    func testRemoveImage() {
        let url = URL(string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg")!
        let image = UIImage(systemName: "star")!

        sut.store(image, for: url)
        sut.removeImage(for: url)

        XCTAssertNil(sut.image(for: url), "Image should be nil after removal")
    }

    func testClearCache() {
        let url1 = URL(string: "https://rickandmortyapi.com/api/character/avatar/3.jpeg")!
        let url2 = URL(string: "https://rickandmortyapi.com/api/character/avatar/4.jpeg")!
        let image = UIImage(systemName: "star")!

        sut.store(image, for: url1)
        sut.store(image, for: url2)
        sut.clearCache()

        XCTAssertNil(sut.image(for: url1), "Cache should be empty after clearCache")
        XCTAssertNil(sut.image(for: url2), "Cache should be empty after clearCache")
    }

    func testOverwriteExistingImage() {
        let url = URL(string: "https://rickandmortyapi.com/api/character/avatar/5.jpeg")!
        let image1 = UIImage(systemName: "star")!
        let image2 = UIImage(systemName: "heart")!

        sut.store(image1, for: url)
        sut.store(image2, for: url)

        XCTAssertNotNil(sut.image(for: url), "Cache should still contain an image after overwrite")
    }
}
