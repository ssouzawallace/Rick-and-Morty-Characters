//
//  CharacterDetailsViewModel.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation

import Combine

class CharactersDetailsViewModel: ObservableObject {
    
    enum Status {
        case loading
        case loaded(character: Character)
    }
    
    @Published var status: Status = .loading
    @Published var errorMessage: String?
    
    private let id: Int
    private let service: Service
    
    init(id: Int, service: Service = ApiService()) {
        self.id = id
        self.service = service
        fetchCharacter()
    }
    
    func retry() {
        fetchCharacter()
    }
    
    private func fetchCharacter() {
        status = .loading
        Task {
            do {
                let character = try await service.getCharacterWith(id: id)
                status = .loaded(character: character)
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
