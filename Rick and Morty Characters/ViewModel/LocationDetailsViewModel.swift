//
//  LocationDetailsViewModel.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation
import Combine

class LocationDetailsViewModel: ObservableObject {

    enum Status {
        case loading
        case loaded(location: Location)
    }

    enum ResidentsStatus {
        case idle
        case loading
        case loaded(characters: [Character])
    }

    @Published var status: Status = .loading
    @Published var residentsStatus: ResidentsStatus = .idle
    @Published var errorMessage: String?

    private let id: Int
    private let service: Service

    init(id: Int, service: Service = ApiService()) {
        self.id = id
        self.service = service
        fetchLocation()
    }

    func retry() {
        fetchLocation()
    }

    func fetchResidents(urls: [String]) {
        guard case .idle = residentsStatus else { return }
        errorMessage = nil
        residentsStatus = .loading
        Task {
            do {
                let characters = try await service.getCharactersByURLs(urls)
                self.residentsStatus = .loaded(characters: characters)
            } catch {
                // Back to .idle so the guard above allows another attempt;
                // leaving it .loading strands the view on a spinner forever.
                self.residentsStatus = .idle
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func fetchLocation() {
        status = .loading
        Task {
            do {
                let location = try await service.getLocationWith(id: id)
                self.status = .loaded(location: location)
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
