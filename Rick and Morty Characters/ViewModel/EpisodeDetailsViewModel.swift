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

    /// Which request failed, so Retry re-issues only that one rather than
    /// reloading the whole screen.
    private enum FailedRequest {
        case episode
        case related(urls: [String])
    }

    private var failedRequest: FailedRequest?

    private let id: Int
    private let service: Service

    init(id: Int, service: Service = ApiService()) {
        self.id = id
        self.service = service
        fetchEpisode()
    }

    func retry() {
        errorMessage = nil

        switch failedRequest {
        case .related(let urls):
            failedRequest = nil
            charactersStatus = .idle
            fetchCharacters(urls: urls)

        case .episode, .none:
            failedRequest = nil
            fetchEpisode()
        }
    }

    func fetchCharacters(urls: [String]) {
        guard case .idle = charactersStatus else { return }
        errorMessage = nil
        charactersStatus = .loading
        Task {
            do {
                let characters = try await service.getCharactersByURLs(urls)
                self.failedRequest = nil
                self.charactersStatus = .loaded(characters: characters)
            } catch {
                // Back to .idle so the guard above allows another attempt;
                // leaving it .loading strands the view on a spinner forever.
                self.charactersStatus = .idle
                self.failedRequest = .related(urls: urls)
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func fetchEpisode() {
        status = .loading
        Task {
            do {
                let episode = try await service.getEpisodeWith(id: id)
                self.failedRequest = nil
                self.status = .loaded(episode: episode)
            } catch {
                self.failedRequest = .episode
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
