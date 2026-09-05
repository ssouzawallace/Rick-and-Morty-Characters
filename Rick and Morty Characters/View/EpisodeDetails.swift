//
//  EpisodeDetails.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct EpisodeDetails: View {

    @ObservedObject private var viewModel: EpisodeDetailsViewModel

    @GalacticBackgroundPreference private var background

    init(id: Int) {
        viewModel = EpisodeDetailsViewModel(id: id)
    }

    var body: some View {
        ZStack {
            background.color.ignoresSafeArea()

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

                        // The count and the cards share one section, and one card
                        // colour, so the whole group reads as a single panel.
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
                                .listRowBackground(background.cardColor)
                                .listRowSeparator(.hidden)

                            case .loaded(let characters):
                                ForEach(characters) { character in
                                    NavigationLink {
                                        CharacterDetails(id: character.id)
                                    } label: {
                                        CharactersListCell(character: character)
                                    }
                                    .buttonStyle(.plain)
                                    .galacticListRow(onPanel: true)
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
        .galacticSettingsToolbar()
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("Retry") {
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
