//
//  Rick_and_Morty_CharactersListViewModelTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Wallace Souza Silva on 11/01/26.
//

import XCTest
@testable import Rick_and_Morty_Characters

@MainActor
final class Rick_and_Morty_CharactersListViewModelTests: XCTestCase {
    
    func testFilters() async throws {
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
        let sut = CharactersListViewModel(service: service)
        
        sut.fetchNextPage()
        
        XCTAssertEqual(sut.currentPage, 2) // Assert the page 2 is being requested
        
        sut.searchText = "a" // Modify the search term change
        
        XCTAssertEqual(sut.status, CharactersListViewModel.Status.loading)
        
        let searchTermExpectation = XCTestExpectation()
        let waitTimeInSeconds: TimeInterval = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeInSeconds, execute: {
            if case .loaded = sut.status {
                searchTermExpectation.fulfill()
            }
        })
        
        await fulfillment(of: [searchTermExpectation], timeout: waitTimeInSeconds + 10)
        
        XCTAssertEqual(sut.currentPage, 1) // Assert the request was reset to the first page
        
        sut.fetchNextPage()
        
        XCTAssertEqual(sut.currentPage, 2) // Assert the page 2 is being requested
        
        sut.searchScope = .unknown // Modify the searchScope a.k.a. search status
        
        XCTAssertEqual(sut.status, CharactersListViewModel.Status.loading)

        let statusExpectation = XCTestExpectation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeInSeconds, execute: {
            if case .loaded = sut.status {
                statusExpectation.fulfill()
            }
        })
        
        await fulfillment(of: [statusExpectation], timeout: waitTimeInSeconds + 10)
    }
}
