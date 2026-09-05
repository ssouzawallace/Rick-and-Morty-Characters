//
//  EpisodeDetailsViewModel.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation
import Combine

class EpisodeDetailsViewModel: ObservableObject {

    enum Status {
        case loading
        case loaded(episode: Episode)
    }

    enum CharactersStatus {
        case idle
        case loading
        case loaded(characters: [Character])
    }

    @Published var status: Status = .loading
    @Published var charactersStatus: CharactersStatus = .idle
    @Published var errorMessage: String?

    private let id: Int
    private let service: Service

    init(id: Int, service: Service = ApiService()) {
        self.id = id
        self.service = service
        fetchEpisode()
    }

    func retry() {
        fetchEpisode()
    }

    func fetchCharacters(urls: [String]) {
        guard case .idle = charactersStatus else { return }
        errorMessage = nil
        charactersStatus = .loading
        Task {
            do {
                let characters = try await service.getCharactersByURLs(urls)
                self.charactersStatus = .loaded(characters: characters)
            } catch {
                // Back to .idle so the guard above allows another attempt;
                // leaving it .loading strands the view on a spinner forever.
                self.charactersStatus = .idle
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func fetchEpisode() {
        status = .loading
        Task {
            do {
                let episode = try await service.getEpisodeWith(id: id)
                self.status = .loaded(episode: episode)
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
