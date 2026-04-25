//
//  Rick_and_Morty_EpisodesServiceTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Wallace Souza Silva
//

import XCTest
@testable import Rick_and_Morty_Characters

@MainActor
final class Rick_and_Morty_EpisodesServiceTests: XCTestCase {

    func testSuccess() async throws {
        guard let responseJSON = episodesListResponseJson.data(using: .utf8) else {
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
        let response = try await service.listEpisodes(name: nil)
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
            let _ = try await service.listEpisodes(name: nil)
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
        let response = try await service.listEpisodes(name: nil)
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
            let _ = try await service.listEpisodes(name: nil)
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

var episodesListResponseJson: String {
    """
    {
       "info":{
          "count":51,
          "pages":3,
          "next":"https://rickandmortyapi.com/api/episode?page=2",
          "prev":null
       },
       "results":[
          {
             "id":1,
             "name":"Pilot",
             "air_date":"December 2, 2013",
             "episode":"S01E01",
             "characters":[
                "https://rickandmortyapi.com/api/character/1",
                "https://rickandmortyapi.com/api/character/2"
             ],
             "url":"https://rickandmortyapi.com/api/episode/1",
             "created":"2017-11-10T12:56:33.798Z"
          },
          {
             "id":2,
             "name":"Lawnmower Dog",
             "air_date":"December 9, 2013",
             "episode":"S01E02",
             "characters":[
                "https://rickandmortyapi.com/api/character/1",
                "https://rickandmortyapi.com/api/character/2"
             ],
             "url":"https://rickandmortyapi.com/api/episode/2",
             "created":"2017-11-10T12:56:33.916Z"
          }
       ]
    }
    """
}
