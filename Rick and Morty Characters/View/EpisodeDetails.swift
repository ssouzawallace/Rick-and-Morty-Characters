//
//  EpisodeDetails.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct EpisodeDetails: View {

    @ObservedObject private var viewModel: EpisodeDetailsViewModel

    init(id: Int) {
        viewModel = EpisodeDetailsViewModel(id: id)
    }

    var body: some View {
        Group {
            switch viewModel.status {
            case .loading:
                ProgressView()
            case .loaded(episode: let episode):
                List {
                    Section {
                        CharacterDetailsFormCell(key: "Name", value: episode.name)
                        CharacterDetailsFormCell(key: "Episode", value: episode.episode)
                        CharacterDetailsFormCell(key: "Air Date", value: episode.airDate)
                    }

                    Section {
                        CharacterDetailsFormCell(key: "Characters", value: episode.characters.count.description)
                        switch viewModel.charactersStatus {
                        case .idle:
                            if !episode.characters.isEmpty {
                                Button("Load Characters") {
                                    viewModel.fetchCharacters(urls: episode.characters)
                                }
                            }
                        case .loading:
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        case .loaded(let characters):
                            ForEach(characters) { character in
                                NavigationLink {
                                    CharacterDetails(id: character.id)
                                } label: {
                                    CharactersListCell(character: character)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .onAppear {
                    if !episode.characters.isEmpty {
                        viewModel.fetchCharacters(urls: episode.characters)
                    }
                }
            }
        }
        .navigationTitle("Episode")
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("Retry") {
                viewModel.errorMessage = nil
                viewModel.retry()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    NavigationStack {
        EpisodeDetails(id: 1)
    }
}
