//
//  Rick_and_Morty_CharactersDetailsViewModelTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Wallace Souza Silva
//

import XCTest
@testable import Rick_and_Morty_Characters

@MainActor
final class Rick_and_Morty_CharactersDetailsViewModelTests: XCTestCase {

    private let waitTimeInSeconds: TimeInterval = 0.5

    // MARK: - Initial Load

    func testInitialStatusIsLoading() {
        let sut = CharactersDetailsViewModel(id: 1, service: MockService())
        if case .loading = sut.status { } else {
            XCTFail("Expected .loading status immediately after init")
        }
    }

    func testInitialLoadSuccess() async throws {
        let service = MockService()
        let sut = CharactersDetailsViewModel(id: 1, service: service)

        let expectation = XCTestExpectation(description: "status becomes loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeInSeconds) {
            if case .loaded = sut.status {
                expectation.fulfill()
            }
        }
        await fulfillment(of: [expectation], timeout: waitTimeInSeconds + 10)

        if case .loaded(let character) = sut.status {
            XCTAssertEqual(character.id, 1)
            XCTAssertEqual(character.name, "Rick Sanchez")
        } else {
            XCTFail("Expected .loaded status")
        }
        XCTAssertNil(sut.errorMessage)
    }

    func testInitialLoadError() async throws {
        let service = MockService(characterResult: .failure(NetworkingError.request(500)))
        let sut = CharactersDetailsViewModel(id: 1, service: service)

        let expectation = XCTestExpectation(description: "errorMessage is set")
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeInSeconds) {
            if sut.errorMessage != nil {
                expectation.fulfill()
            }
        }
        await fulfillment(of: [expectation], timeout: waitTimeInSeconds + 10)

        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Retry

    func testRetryResetsStatusToLoadingThenLoaded() async throws {
        let service = MockService()
        let sut = CharactersDetailsViewModel(id: 1, service: service)

        // Wait for initial load
        let initialExpectation = XCTestExpectation(description: "initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeInSeconds) {
            if case .loaded = sut.status {
                initialExpectation.fulfill()
            }
        }
        await fulfillment(of: [initialExpectation], timeout: waitTimeInSeconds + 10)

        // Retry sets status back to loading synchronously
        sut.retry()
        if case .loading = sut.status { } else {
            XCTFail("Expected .loading status immediately after retry()")
        }

        // Then becomes loaded again
        let retryExpectation = XCTestExpectation(description: "retry loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeInSeconds) {
            if case .loaded = sut.status {
                retryExpectation.fulfill()
            }
        }
        await fulfillment(of: [retryExpectation], timeout: waitTimeInSeconds + 10)

        if case .loaded(let character) = sut.status {
            XCTAssertEqual(character.id, 1)
        } else {
            XCTFail("Expected .loaded status after retry")
        }
    }

    func testRetryAfterErrorClearsAndLoads() async throws {
        // First attempt fails, retry succeeds
        var callCount = 0
        let failingResult: Result<Character, Error> = .failure(NetworkingError.request(500))
        let successResult: Result<Character, Error> = .success(testCharacter)

        // Use a class to hold mutable state accessible from the service
        final class Counter { var value = 0 }
        let counter = Counter()

        struct CountingService: Service {
            let counter: Counter
            let failingResult: Result<Character, Error>
            let successResult: Result<Character, Error>

            func getCharacterWith(id: Int) async throws -> Character {
                counter.value += 1
                return try (counter.value == 1 ? failingResult : successResult).get()
            }

            func listCharacters(page: Int, name: String?, status: String?) async throws -> GetAllCharactersResponse {
                try GetAllCharactersResponse(
                    info: GetAllCharactersResponse.Info(next: nil),
                    results: []
                ) as GetAllCharactersResponse
            }
        }

        let service = CountingService(counter: counter, failingResult: failingResult, successResult: successResult)
        let sut = CharactersDetailsViewModel(id: 1, service: service)

        // Wait for initial (failing) load
        let errorExpectation = XCTestExpectation(description: "error from first load")
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeInSeconds) {
            if sut.errorMessage != nil {
                errorExpectation.fulfill()
            }
        }
        await fulfillment(of: [errorExpectation], timeout: waitTimeInSeconds + 10)
        XCTAssertNotNil(sut.errorMessage)

        // Retry should succeed
        sut.retry()
        let retryExpectation = XCTestExpectation(description: "retry succeeds")
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTimeInSeconds) {
            if case .loaded = sut.status {
                retryExpectation.fulfill()
            }
        }
        await fulfillment(of: [retryExpectation], timeout: waitTimeInSeconds + 10)

        if case .loaded(let character) = sut.status {
            XCTAssertEqual(character.id, 1)
        } else {
            XCTFail("Expected .loaded status after successful retry")
        }
    }
}
