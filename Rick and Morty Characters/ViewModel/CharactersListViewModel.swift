//
//  CharactersListViewModel.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation
import Combine

class CharactersListViewModel: ObservableObject {
    
    private let debounceIntervalInMillis = 250
    
    enum Status: Equatable {
        case loading
        case loaded(characters: [Character])
        
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
    @Published var searchScope: CharacterStatus = .undefined{
        didSet {
            fetchInitialData()
        }
    }
    @Published var status: Status = .loading
    @Published var errorMessage: String?
    
    var hasMoreData = true
    
    var currentPage: Int {
        page
    }
    
    private let service: Service
    
    private var page = 1
    
    private var cancellables = Set<AnyCancellable>()

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
        page = 1
        fetchCharacters(page: currentPage)
    }
    
    func fetchNextPage() {
        page += 1
        fetchCharacters(page: currentPage)
    }
    
    private func fetchCharacters(page: Int) {
        Task {
            do {
                let response = try await service.listCharacters(page: page, name: searchText.isEmpty ? nil : searchText, status: searchScope == .undefined ? nil : searchScope.rawValue)
                
                if page == 1 {
                    self.status = .loaded(characters: response.results)
                } else if case .loaded(characters: let previousData) = status {
                    hasMoreData = response.info.next != nil
                    self.status = .loaded(characters: previousData + response.results)
                }
                
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

}
