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

    // MARK: - Initial Load

    func testInitialDataLoaded() async throws {
        let service = MockService()
        let sut = CharactersListViewModel(service: service)

        let expectation = XCTestExpectation(description: "initial data loaded")
        let waitTimeInSeconds: TimeInterval = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeInSeconds) {
            if case .loaded = sut.status {
                expectation.fulfill()
            }
        }
        await fulfillment(of: [expectation], timeout: waitTimeInSeconds + 10)

        if case .loaded(let characters) = sut.status {
            XCTAssertEqual(characters.count, 1)
        } else {
            XCTFail("Expected .loaded status after init")
        }
        XCTAssertEqual(sut.currentPage, 1)
    }

    // MARK: - Pagination

    func testFetchNextPageAppendsCharacters() async throws {
        let service = MockService()
        let sut = CharactersListViewModel(service: service)
        let waitTimeInSeconds: TimeInterval = 0.5

        // Wait for initial load to complete
        let initialExpectation = XCTestExpectation(description: "initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeInSeconds) {
            if case .loaded = sut.status {
                initialExpectation.fulfill()
            }
        }
        await fulfillment(of: [initialExpectation], timeout: waitTimeInSeconds + 10)

        sut.fetchNextPage()
        XCTAssertEqual(sut.currentPage, 2)

        let nextPageExpectation = XCTestExpectation(description: "next page appended")
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeInSeconds) {
            if case .loaded(let characters) = sut.status, characters.count == 2 {
                nextPageExpectation.fulfill()
            }
        }
        await fulfillment(of: [nextPageExpectation], timeout: waitTimeInSeconds + 10)

        if case .loaded(let characters) = sut.status {
            XCTAssertEqual(characters.count, 2)
        } else {
            XCTFail("Expected .loaded status with appended characters")
        }
    }

    func testHasMoreDataFalseWhenNoNextPage() async throws {
        let noNextResponse = GetAllCharactersResponse(
            info: GetAllCharactersResponse.Info(next: nil),
            results: [testCharacter]
        )
        let service = MockService(listResult: .success(noNextResponse))
        let sut = CharactersListViewModel(service: service)
        let waitTimeInSeconds: TimeInterval = 0.5

        // Wait for initial load
        let initialExpectation = XCTestExpectation(description: "initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeInSeconds) {
            if case .loaded = sut.status {
                initialExpectation.fulfill()
            }
        }
        await fulfillment(of: [initialExpectation], timeout: waitTimeInSeconds + 10)

        sut.fetchNextPage()

        let nextPageExpectation = XCTestExpectation(description: "next page processed")
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeInSeconds) {
            nextPageExpectation.fulfill()
        }
        await fulfillment(of: [nextPageExpectation], timeout: waitTimeInSeconds + 10)

        XCTAssertFalse(sut.hasMoreData)
    }

    // MARK: - Error Handling

    func testNetworkErrorSetsErrorMessage() async throws {
        let service = MockService(listResult: .failure(NetworkingError.request(500)))
        let sut = CharactersListViewModel(service: service)
        let waitTimeInSeconds: TimeInterval = 0.5

        let expectation = XCTestExpectation(description: "errorMessage set")
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeInSeconds) {
            if sut.errorMessage != nil {
                expectation.fulfill()
            }
        }
        await fulfillment(of: [expectation], timeout: waitTimeInSeconds + 10)

        XCTAssertNotNil(sut.errorMessage)
    }
}
