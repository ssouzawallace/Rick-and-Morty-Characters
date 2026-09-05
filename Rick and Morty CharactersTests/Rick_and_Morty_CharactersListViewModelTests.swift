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

    /// Polls until `condition` holds. The previous version sampled the status
    /// once, half a second in: if the 250 ms debounce and the request had not
    /// both finished by exactly that instant the expectation was never
    /// fulfilled, and the test hung until it timed out. That passed locally and
    /// failed on a loaded CI runner.
    private func wait(
        timeout: TimeInterval = 5,
        until condition: @escaping () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition(), Date() < deadline {
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
    }

    private func makeViewModel() throws -> CharactersListViewModel {
        let responseJSON = try XCTUnwrap(
            listResponseJson.data(using: .utf8),
            "Response JSON is not in the correct format"
        )

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, responseJSON)
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

        return CharactersListViewModel(
            service: ApiService(urlSession: URLSession(configuration: configuration))
        )
    }

    private func isLoaded(_ viewModel: CharactersListViewModel) -> Bool {
        if case .loaded = viewModel.status { return true }
        return false
    }

    func testSearchTextResetsToTheFirstPage() async throws {
        let sut = try makeViewModel()

        sut.fetchNextPage()
        XCTAssertEqual(sut.currentPage, 2, "Paging should ask for page 2")

        sut.searchText = "a"
        XCTAssertEqual(sut.status, .loading)

        await wait { self.isLoaded(sut) }

        XCTAssertTrue(isLoaded(sut), "The search should have loaded")
        XCTAssertEqual(sut.currentPage, 1, "A new search starts from page 1")
    }

    func testSearchScopeResetsToTheFirstPage() async throws {
        let sut = try makeViewModel()

        await wait { self.isLoaded(sut) }

        sut.fetchNextPage()
        XCTAssertEqual(sut.currentPage, 2, "Paging should ask for page 2")

        sut.searchScope = .unknown
        XCTAssertEqual(sut.status, .loading)

        await wait { self.isLoaded(sut) }

        XCTAssertTrue(isLoaded(sut), "The filter should have loaded")
        XCTAssertEqual(sut.currentPage, 1, "A new filter starts from page 1")
    }
}
