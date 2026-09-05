//
//  Rick_and_Morty_GetCharactersByURLsTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Wallace Souza Silva
//

import XCTest
@testable import Rick_and_Morty_Characters

@MainActor
final class Rick_and_Morty_GetCharactersByURLsTests: XCTestCase {

    private func makeService(
        handler: @escaping (URLRequest) throws -> (HTTPURLResponse, Data)
    ) -> ApiService {
        MockURLProtocol.requestHandler = handler
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return ApiService(urlSession: URLSession(configuration: configuration))
    }

    private func characterJson(id: Int, name: String) -> String {
        """
        {
            "id": \(id),
            "name": "\(name)",
            "status": "Alive",
            "species": "Human",
            "type": "",
            "gender": "Male",
            "origin": { "name": "Earth", "url": "" },
            "location": { "name": "Citadel", "url": "" },
            "image": "https://rickandmortyapi.com/api/character/avatar/\(id).jpeg",
            "episode": [],
            "url": "https://rickandmortyapi.com/api/character/\(id)",
            "created": "2017-11-04T18:48:46.250Z"
        }
        """
    }

    private func url(forId id: Int) -> String {
        "https://rickandmortyapi.com/api/character/\(id)"
    }

    // MARK: - Batching

    /// The whole point of the change: a hundred residents must not become a
    /// hundred requests, which is what got the app rate limited.
    func testFetchesEveryCharacterInASingleRequest() async throws {
        let ids = Array(1 ... 100)
        let body = "[" + ids.map { characterJson(id: $0, name: "Rick \($0)") }.joined(separator: ",") + "]"

        var requestedPaths: [String] = []
        let service = makeService { request in
            requestedPaths.append(request.url?.path ?? "")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(body.utf8))
        }

        let characters = try await service.getCharactersByURLs(ids.map(url(forId:)))

        XCTAssertEqual(characters.count, 100)
        XCTAssertEqual(requestedPaths.count, 1, "100 ids should cost exactly one request")
        XCTAssertEqual(requestedPaths.first, "/api/character/" + ids.map(String.init).joined(separator: ","))
    }

    func testSplitsIntoOneRequestPerHundred() async throws {
        let ids = Array(1 ... 150)
        var requestCount = 0

        let service = makeService { request in
            requestCount += 1
            let idCount = (request.url?.lastPathComponent ?? "").split(separator: ",").count
            let body = "[" + (1 ... idCount).map { self.characterJson(id: $0 + requestCount * 1000, name: "Rick") }
                .joined(separator: ",") + "]"
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(body.utf8))
        }

        let characters = try await service.getCharactersByURLs(ids.map(url(forId:)))

        XCTAssertEqual(requestCount, 2, "150 ids should be split into 100 + 50")
        XCTAssertEqual(characters.count, 150)
    }

    /// A single id returns an object, not an array — the API is inconsistent here.
    func testSingleIdDecodesAnObjectRatherThanAnArray() async throws {
        let service = makeService { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(self.characterJson(id: 42, name: "Birdperson").utf8))
        }

        let characters = try await service.getCharactersByURLs([url(forId: 42)])

        XCTAssertEqual(characters.count, 1)
        XCTAssertEqual(characters.first?.id, 42)
    }

    func testResultsAreSortedById() async throws {
        let body = "[" + [characterJson(id: 9, name: "Nine"), characterJson(id: 2, name: "Two")].joined(separator: ",") + "]"
        let service = makeService { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(body.utf8))
        }

        let characters = try await service.getCharactersByURLs([url(forId: 9), url(forId: 2)])

        XCTAssertEqual(characters.map(\.id), [2, 9])
    }

    func testEmptyInputMakesNoRequest() async throws {
        var requestCount = 0
        let service = makeService { request in
            requestCount += 1
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data("[]".utf8))
        }

        let characters = try await service.getCharactersByURLs([])

        XCTAssertTrue(characters.isEmpty)
        XCTAssertEqual(requestCount, 0)
    }

    // MARK: - Failures

    func testMalformedUrlThrowsBadUrl() async {
        let service = makeService { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data("[]".utf8))
        }

        do {
            _ = try await service.getCharactersByURLs(["https://rickandmortyapi.com/api/character/not-a-number"])
            XCTFail("Expected badUrl")
        } catch NetworkingError.badUrl {
            // expected
        } catch {
            XCTFail("Expected badUrl, got \(error)")
        }
    }

    func testRateLimitSurfacesTheStatusCode() async {
        let service = makeService { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 429, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        do {
            _ = try await service.getCharactersByURLs([url(forId: 1), url(forId: 2)])
            XCTFail("Expected request(429)")
        } catch NetworkingError.request(let statusCode) {
            XCTAssertEqual(statusCode, 429)
        } catch {
            XCTFail("Expected request(429), got \(error)")
        }
    }

    // MARK: - Messages

    /// The alert used to read "NetworkingError error 0" for every failure.
    func testErrorsDescribeThemselves() {
        XCTAssertEqual(
            (NetworkingError.request(429) as NSError).localizedDescription,
            "The Rick and Morty API is rate limiting requests (429). Wait a moment and try again."
        )
        XCTAssertEqual(
            (NetworkingError.request(404) as NSError).localizedDescription,
            "The Rick and Morty API has nothing at that address (404)."
        )
        XCTAssertEqual(
            (NetworkingError.badUrl as NSError).localizedDescription,
            "Could not build a valid request for the Rick and Morty API."
        )
    }
}
