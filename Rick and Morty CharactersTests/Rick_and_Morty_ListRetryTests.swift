//
//  Rick_and_Morty_ListRetryTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Wallace Souza Silva
//

import XCTest
@testable import Rick_and_Morty_Characters

/// Retry must re-issue only the request that failed. Reloading the screen threw
/// away every page already on screen, which is very visible when the API rate
/// limits a later page.
@MainActor
final class Rick_and_Morty_ListRetryTests: XCTestCase {

    // MARK: - Helpers

    private func character(id: Int) -> Character {
        Character(
            id: id,
            name: "Rick \(id)",
            status: .alive,
            species: "Human",
            type: "",
            gender: .male,
            origin: CharacterPlacement(name: "Earth", url: ""),
            location: CharacterPlacement(name: "Citadel", url: ""),
            image: "",
            episode: [],
            url: "",
            created: nil
        )
    }

    private func page(ids: [Int], hasNext: Bool) -> GetAllCharactersResponse {
        GetAllCharactersResponse(
            info: .init(next: hasNext ? "https://rickandmortyapi.com/api/character?page=2" : nil),
            results: ids.map(character(id:))
        )
    }

    private func wait(
        timeout: TimeInterval = 2,
        until condition: @escaping () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition(), Date() < deadline {
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
    }

    private func loadedIds(_ viewModel: CharactersListViewModel) -> [Int] {
        guard case .loaded(let characters) = viewModel.status else { return [] }
        return characters.map(\.id)
    }

    /// A view model with its first page already on screen.
    private func makeLoadedViewModel() async -> (CharactersListViewModel, MockService) {
        let service = MockService()
        service.listCharactersResult = .success(page(ids: [1, 2], hasNext: true))

        let viewModel = CharactersListViewModel(service: service)
        await wait { if case .loaded = viewModel.status { return true } else { return false } }

        return (viewModel, service)
    }

    // MARK: - A failed later page

    func testFailedPageKeepsTheRowsAlreadyLoaded() async {
        let (viewModel, service) = await makeLoadedViewModel()
        XCTAssertEqual(loadedIds(viewModel), [1, 2])

        service.listCharactersResult = .failure(NetworkingError.request(429))
        viewModel.fetchNextPage()
        await wait { viewModel.errorMessage != nil }

        XCTAssertEqual(
            loadedIds(viewModel), [1, 2],
            "The first page must survive a failure on the second"
        )
    }

    func testRetryReissuesOnlyTheFailedPage() async {
        let (viewModel, service) = await makeLoadedViewModel()

        service.listCharactersResult = .failure(NetworkingError.request(429))
        viewModel.fetchNextPage()
        await wait { viewModel.errorMessage != nil }
        XCTAssertEqual(service.lastRequestedPage, 2)

        let callsBeforeRetry = service.listCharactersCallCount
        service.listCharactersResult = .success(page(ids: [3, 4], hasNext: false))
        viewModel.retry()
        await wait { self.loadedIds(viewModel).count == 4 }

        XCTAssertEqual(service.lastRequestedPage, 2, "Retry should ask for page 2 again, not page 1")
        XCTAssertEqual(service.listCharactersCallCount, callsBeforeRetry + 1, "Exactly one request")
        XCTAssertEqual(loadedIds(viewModel), [1, 2, 3, 4], "Page 2 appends to page 1")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testPagingStopsAdvancingWhileAnErrorIsShowing() async {
        let (viewModel, service) = await makeLoadedViewModel()

        service.listCharactersResult = .failure(NetworkingError.request(429))
        viewModel.fetchNextPage()
        await wait { viewModel.errorMessage != nil }

        let callsAfterFailure = service.listCharactersCallCount

        // The paging footer is still on screen behind the alert and keeps firing.
        viewModel.fetchNextPage()
        viewModel.fetchNextPage()

        XCTAssertEqual(
            service.listCharactersCallCount, callsAfterFailure,
            "No further requests while the error is up"
        )
        XCTAssertEqual(viewModel.currentPage, 2, "The page counter must not run ahead")
    }

    // MARK: - A failed first page

    func testRetryReloadsFromScratchWhenTheFirstPageFailed() async {
        let service = MockService()
        service.listCharactersResult = .failure(NetworkingError.request(429))

        let viewModel = CharactersListViewModel(service: service)
        await wait { viewModel.errorMessage != nil }
        XCTAssertEqual(loadedIds(viewModel), [], "Nothing loaded yet")

        service.listCharactersResult = .success(page(ids: [1, 2], hasNext: false))
        viewModel.retry()
        await wait { !self.loadedIds(viewModel).isEmpty }

        XCTAssertEqual(service.lastRequestedPage, 1)
        XCTAssertEqual(loadedIds(viewModel), [1, 2])
        XCTAssertNil(viewModel.errorMessage)
    }
}
