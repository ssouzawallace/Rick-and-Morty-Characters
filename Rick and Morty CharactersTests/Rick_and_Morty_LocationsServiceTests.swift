//
//  Rick_and_Morty_LocationsServiceTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Wallace Souza Silva
//

import XCTest
@testable import Rick_and_Morty_Characters

@MainActor
final class Rick_and_Morty_LocationsServiceTests: XCTestCase {

    func testSuccess() async throws {
        guard let responseJSON = locationsListResponseJson.data(using: .utf8) else {
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
        let response = try await service.listLocations(name: nil)
        XCTAssertEqual(response.results.count, 2)
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
            let _ = try await service.listLocations(name: nil)
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
        let response = try await service.listLocations(name: nil)
        XCTAssertEqual(response.results.count, 0)
    }

    func testFailureHttp500() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let service = ApiService(urlSession: session)

        do {
            let _ = try await service.listLocations(name: nil)
            XCTFail("Expected error to be thrown")
        } catch {
            if case NetworkingError.request(let statusCode) = error, statusCode == 500 {
                return // Expected
            } else {
                XCTFail("Expected NetworkingError.request(500), got \(error)")
            }
        }
    }
}

var locationsListResponseJson: String {
    """
    {
       "info":{
          "count":126,
          "pages":7,
          "next":"https://rickandmortyapi.com/api/location?page=2",
          "prev":null
       },
       "results":[
          {
             "id":1,
             "name":"Earth (C-137)",
             "type":"Planet",
             "dimension":"Dimension C-137",
             "residents":[
                "https://rickandmortyapi.com/api/character/38",
                "https://rickandmortyapi.com/api/character/45"
             ],
             "url":"https://rickandmortyapi.com/api/location/1",
             "created":"2017-11-10T12:42:04.162Z"
          },
          {
             "id":2,
             "name":"Abadango",
             "type":"Cluster",
             "dimension":"unknown",
             "residents":[
                "https://rickandmortyapi.com/api/character/6"
             ],
             "url":"https://rickandmortyapi.com/api/location/2",
             "created":"2017-11-10T13:06:38.182Z"
          }
       ]
    }
    """
}
