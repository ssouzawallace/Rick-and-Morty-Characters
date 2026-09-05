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
        ZStack {
            GalacticTheme.spaceBackground.ignoresSafeArea()

            Group {
                switch viewModel.status {
                case .loading:
                    GalacticLoadingView()

                case .loaded(episode: let episode):
                    List {
                        Section {
                            CharacterDetailsFormCell(key: "Name", value: episode.name)
                            CharacterDetailsFormCell(key: "Episode", value: episode.episode)
                            CharacterDetailsFormCell(key: "Air Date", value: episode.airDate)
                        } header: {
                            GalacticSectionHeader("Episode")
                        }

                        Section {
                            CharacterDetailsFormCell(
                                key: "Total Characters",
                                value: episode.characters.count.description
                            )

                            switch viewModel.charactersStatus {
                            case .idle:
                                EmptyView()

                            case .loading:
                                HStack {
                                    Spacer()
                                    GalacticInlineSpinner()
                                        .padding(.vertical, 12)
                                    Spacer()
                                }
                                .listRowBackground(GalacticTheme.spaceBackground)
                                .listRowSeparator(.hidden)

                            case .loaded(let characters):
                                ForEach(characters) { character in
                                    NavigationLink {
                                        CharacterDetails(id: character.id)
                                    } label: {
                                        CharactersListCell(character: character)
                                    }
                                    .buttonStyle(.plain)
                                    .galacticListRow()
                                }
                            }
                        } header: {
                            GalacticSectionHeader("Characters")
                        }
                    }
                    .galacticList()
                    .listStyle(.insetGrouped)
                    .navigationLinkIndicatorVisibility(.hidden)
                    .onAppear {
                        if !episode.characters.isEmpty {
                            viewModel.fetchCharacters(urls: episode.characters)
                        }
                    }
                }
            }
        }
        .navigationTitle("Episode")
        .galacticNavigationBar()
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
