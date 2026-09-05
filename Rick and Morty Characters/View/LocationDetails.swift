//
//  LocationDetails.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct LocationDetails: View {

    @ObservedObject private var viewModel: LocationDetailsViewModel

    @GalacticBackgroundPreference private var background

    init(id: Int) {
        viewModel = LocationDetailsViewModel(id: id)
    }

    var body: some View {
        ZStack {
            background.color.ignoresSafeArea()

            Group {
                switch viewModel.status {
                case .loading:
                    GalacticLoadingView()

                case .loaded(location: let location):
                    List {
                        Section {
                            CharacterDetailsFormCell(key: "Name", value: location.name)
                            CharacterDetailsFormCell(key: "Type", value: location.type)
                            CharacterDetailsFormCell(key: "Dimension", value: location.dimension)
                        } header: {
                            GalacticSectionHeader("Location")
                        }

                        // The count and the cards share one section, and one card
                        // colour, so the whole group reads as a single panel.
                        Section {
                            CharacterDetailsFormCell(
                                key: "Total Residents",
                                value: location.residents.count.description
                            )

                            switch viewModel.residentsStatus {
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
                            GalacticSectionHeader("Residents")
                        }
                    }
                    .galacticList()
                    .listStyle(.insetGrouped)
                    .navigationLinkIndicatorVisibility(.hidden)
                    .onAppear {
                        if !location.residents.isEmpty {
                            viewModel.fetchResidents(urls: location.residents)
                        }
                    }
                }
            }
        }
        .navigationTitle("Location")
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
        LocationDetails(id: 1)
    }
}
