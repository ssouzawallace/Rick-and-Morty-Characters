//
//  Rick_and_Morty_GetCharacterServiceTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Copilot
//

import XCTest
@testable import Rick_and_Morty_Characters

@MainActor
final class Rick_and_Morty_GetCharacterServiceTests: XCTestCase {

    // MARK: - Helpers

    private func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    // MARK: - getCharacterWith Success

    func testGetCharacterSuccess() async throws {
        guard let responseJSON = singleCharacterJson.data(using: .utf8) else {
            XCTFail("Response JSON is not in the correct format")
            return
        }
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseJSON)
        }

        let service = ApiService(urlSession: makeSession())
        let character = try await service.getCharacterWith(id: 1)

        XCTAssertEqual(character.id, 1)
        XCTAssertEqual(character.name, "Rick Sanchez")
        XCTAssertEqual(character.status, .alive)
        XCTAssertEqual(character.gender, .male)
    }

    // MARK: - getCharacterWith HTTP Error

    func testGetCharacterHttp500ThrowsError() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let service = ApiService(urlSession: makeSession())

        do {
            _ = try await service.getCharacterWith(id: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            if case NetworkingError.request(let statusCode) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Expected NetworkingError.request(500), got \(error)")
            }
        }
    }

    func testGetCharacterHttp404ThrowsError() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let service = ApiService(urlSession: makeSession())

        do {
            _ = try await service.getCharacterWith(id: 999)
            XCTFail("Expected error to be thrown")
        } catch {
            if case NetworkingError.request(let statusCode) = error {
                XCTAssertEqual(statusCode, 404)
            } else {
                XCTFail("Expected NetworkingError.request(404), got \(error)")
            }
        }
    }

    // MARK: - getCharacterWith Decoding Error

    func testGetCharacterDecodingError() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let service = ApiService(urlSession: makeSession())

        do {
            _ = try await service.getCharacterWith(id: 1)
            XCTFail("Expected decoding error to be thrown")
        } catch {
            if case DecodingError.dataCorrupted(_) = error {
                return // Expected
            } else {
                XCTFail("Expected DecodingError, got \(error)")
            }
        }
    }

    // MARK: - listCharacters with Name and Status Filters

    func testListCharactersWithNameFilter() async throws {
        guard let responseJSON = listResponseJson.data(using: .utf8) else {
            XCTFail("Response JSON is not in the correct format")
            return
        }
        MockURLProtocol.requestHandler = { request in
            // Verify the URL contains the name parameter
            XCTAssertTrue(request.url!.absoluteString.contains("name=Rick"))
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseJSON)
        }

        let service = ApiService(urlSession: makeSession())
        let response = try await service.listCharacters(page: 1, name: "Rick", status: nil)
        XCTAssertEqual(response.results.count, 3)
    }

    func testListCharactersWithStatusFilter() async throws {
        guard let responseJSON = listResponseJson.data(using: .utf8) else {
            XCTFail("Response JSON is not in the correct format")
            return
        }
        MockURLProtocol.requestHandler = { request in
            // Verify the URL contains the status parameter
            XCTAssertTrue(request.url!.absoluteString.contains("status=alive"))
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseJSON)
        }

        let service = ApiService(urlSession: makeSession())
        let response = try await service.listCharacters(page: 1, name: nil, status: "alive")
        XCTAssertEqual(response.results.count, 3)
    }

    func testListCharactersWithBothFilters() async throws {
        guard let responseJSON = listResponseJson.data(using: .utf8) else {
            XCTFail("Response JSON is not in the correct format")
            return
        }
        MockURLProtocol.requestHandler = { request in
            let url = request.url!.absoluteString
            XCTAssertTrue(url.contains("name=Rick"))
            XCTAssertTrue(url.contains("status=alive"))
            XCTAssertTrue(url.contains("page=2"))
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseJSON)
        }

        let service = ApiService(urlSession: makeSession())
        let response = try await service.listCharacters(page: 2, name: "Rick", status: "alive")
        XCTAssertEqual(response.results.count, 3)
    }
}
