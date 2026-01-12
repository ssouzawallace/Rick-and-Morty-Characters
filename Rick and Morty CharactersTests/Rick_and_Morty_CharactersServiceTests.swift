//
//  Rick_and_Morty_CharactersServiceTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Wallace Souza Silva
//

import XCTest
@testable import Rick_and_Morty_Characters

@MainActor
final class Rick_and_Morty_CharactersServiceTests: XCTestCase {

    func testSuccess() async throws {
        guard let responseJSON = listResponseJson.data(using: .utf8) else {
            XCTFail("Response JSON is not in the correct format")
            return
        }
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseJSON)
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let service = ApiService(urlSession: session)
        let response = try await service.listCharacters(name: nil, status: nil)
        XCTAssertEqual(response.results.count, 3)
    }
    
    func testFailureDecodingError() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let service = ApiService(urlSession: session)
        do {
            let _ = try await service.listCharacters(name: nil, status: nil)
            XCTFail("Expected error to be thrown")
        } catch {
            if case DecodingError.dataCorrupted(_) = error {
                return // Expected
            } else {
                XCTFail("Expected DecodingError, got \(error)")
            }
        }
    }

    func testFailureHttp404() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let service = ApiService(urlSession: session)
        do {
            let _ = try await service.listCharacters(name: nil, status: nil)
            XCTFail("Expected error to be thrown")
        } catch {
            if case NetworkingError.request(let statusCode) = error, statusCode == 404 {
                return // Expected
            } else {
                XCTFail("Expected NetWorkingerror.request(404), got \(error)")
            }
        }
    }
}
