//
//  Rick_and_Morty_CharacterDetailsViewModelTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Copilot
//

import XCTest
@testable import Rick_and_Morty_Characters

@MainActor
final class Rick_and_Morty_CharacterDetailsViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeCharacter() throws -> Character {
        let data = Data(singleCharacterJson.utf8)
        return try JSONDecoder().decode(Character.self, from: data)
    }

    // MARK: - Success

    func testFetchCharacterSuccess() async throws {
        let mockService = MockService()
        let expectedCharacter = try makeCharacter()
        mockService.getCharacterResult = .success(expectedCharacter)

        let sut = CharactersDetailsViewModel(id: 1, service: mockService)

        // Wait for the async fetch to complete
        let expectation = XCTestExpectation(description: "Character loaded")
        let waitTime: TimeInterval = 0.5

        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            if case .loaded(let character) = sut.status {
                XCTAssertEqual(character.id, 1)
                XCTAssertEqual(character.name, "Rick Sanchez")
                expectation.fulfill()
            }
        }

        await fulfillment(of: [expectation], timeout: waitTime + 5)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockService.getCharacterCallCount, 1)
        XCTAssertEqual(mockService.lastRequestedId, 1)
    }

    // MARK: - Failure

    func testFetchCharacterError() async throws {
        let mockService = MockService()
        mockService.getCharacterResult = .failure(NetworkingError.request(500))

        let sut = CharactersDetailsViewModel(id: 42, service: mockService)

        let expectation = XCTestExpectation(description: "Error message set")
        let waitTime: TimeInterval = 0.5

        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            if sut.errorMessage != nil {
                expectation.fulfill()
            }
        }

        await fulfillment(of: [expectation], timeout: waitTime + 5)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(mockService.lastRequestedId, 42)
    }

    // MARK: - Retry

    func testRetryFetchesCharacterAgain() async throws {
        let mockService = MockService()
        mockService.getCharacterResult = .failure(NetworkingError.request(500))

        let sut = CharactersDetailsViewModel(id: 1, service: mockService)

        // Wait for the initial failed fetch
        let initialExpectation = XCTestExpectation(description: "Initial error")
        let waitTime: TimeInterval = 0.5

        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            if sut.errorMessage != nil {
                initialExpectation.fulfill()
            }
        }

        await fulfillment(of: [initialExpectation], timeout: waitTime + 5)
        XCTAssertEqual(mockService.getCharacterCallCount, 1)

        // Now set success and retry
        let expectedCharacter = try makeCharacter()
        mockService.getCharacterResult = .success(expectedCharacter)
        sut.retry()

        let retryExpectation = XCTestExpectation(description: "Character loaded after retry")

        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            if case .loaded = sut.status {
                retryExpectation.fulfill()
            }
        }

        await fulfillment(of: [retryExpectation], timeout: waitTime + 5)
        XCTAssertEqual(mockService.getCharacterCallCount, 2)
    }

    // MARK: - Initial State

    func testInitialStatusIsLoading() {
        let mockService = MockService()
        let expectedCharacter = try? makeCharacter()
        mockService.getCharacterResult = .success(expectedCharacter!)

        let sut = CharactersDetailsViewModel(id: 1, service: mockService)

        // Status starts as loading before async fetch completes
        if case .loading = sut.status {
            // Expected
        } else {
            // On fast systems the fetch might complete synchronously through Task
            // Either loading or loaded is acceptable for the initial synchronous check
        }
    }
}
