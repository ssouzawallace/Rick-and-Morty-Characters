//
//  LocationsListViewModel.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation
import Combine

class LocationsListViewModel: ObservableObject {

    private let debounceIntervalInMillis = 250

    enum Status: Equatable {
        case loading
        case loaded(locations: [Location])

        static func == (lhs: Self, rhs: Self) -> Bool {
            if case .loading = lhs, case .loading = rhs {
                return true
            } else if case .loaded(let lhsValue) = lhs, case .loaded(let rhsValue) = rhs {
                return lhsValue == rhsValue
            } else {
                return false
            }
        }
    }

    @Published var searchText: String = ""
    @Published var status: Status = .loading
    @Published var errorMessage: String?

    var hasMoreData = true

    var currentPage: Int {
        page
    }

    private let service: Service
    private var page = 1
    private var cancellables = Set<AnyCancellable>()
    private var fetchTask: Task<Void, Never>?

    /// The page whose request failed, so Retry can re-issue just that page
    /// instead of discarding the rows already on screen.
    private var failedPage: Int?

    init(service: Service = ApiService()) {
        self.service = service
        fetchInitialData()

        $searchText
            .dropFirst()
            .removeDuplicates()
            .debounce(for: .milliseconds(debounceIntervalInMillis), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchInitialData()
            }
            .store(in: &cancellables)
    }

    func fetchInitialData() {
        status = .loading
        errorMessage = nil
        failedPage = nil
        hasMoreData = true
        page = 1
        fetchLocations(page: currentPage)
    }

    func fetchNextPage() {
        // The paging footer stays on screen behind the alert; without this its
        // onAppear would keep incrementing the page and skip whole pages.
        guard errorMessage == nil else { return }

        page += 1
        fetchLocations(page: currentPage)
    }

    /// Re-issues only the request that failed. A failed second page must not
    /// throw away the first one, which is what reloading the screen did.
    func retry() {
        guard let failedPage else {
            fetchInitialData()
            return
        }

        errorMessage = nil
        self.failedPage = nil
        fetchLocations(page: failedPage)
    }

    private func fetchLocations(page: Int) {
        fetchTask?.cancel()
        fetchTask = Task {
            do {
                let response = try await service.listLocations(page: page, name: searchText.isEmpty ? nil : searchText)

                guard !Task.isCancelled else { return }

                failedPage = nil
                hasMoreData = response.info.next != nil

                if page == 1 {
                    self.status = .loaded(locations: response.results)
                } else if case .loaded(locations: let previousData) = status {
                    self.status = .loaded(locations: previousData + response.results)
                }
            } catch is CancellationError {
                // Superseded by a newer search or page request.
            } catch let error as URLError where error.code == .cancelled {
                // Superseded by a newer search or page request.
            } catch {
                guard !Task.isCancelled else { return }
                self.failedPage = page
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
