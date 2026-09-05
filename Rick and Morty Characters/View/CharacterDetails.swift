//
//  CharacterDetails.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct CharacterDetails: View {
    
    @ObservedObject private var viewModel: CharactersDetailsViewModel
    
    @GalacticBackgroundPreference private var background

    init(id: Int) {
        viewModel = CharactersDetailsViewModel(id: id)
    }
    
    var body: some View {
        ZStack {
            background.color.ignoresSafeArea()

            Group {
                switch viewModel.status {
                case .loading:
                    GalacticLoadingView()
                case .loaded(character: let character):
                    List {
                        // Portrait section
                        Section {
                            CachedAsyncImage(
                                url: URL(string: character.image),
                                content: { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(GalacticTheme.portalGreen.opacity(0.5), lineWidth: 1.5)
                                        )
                                        .shadow(color: GalacticTheme.portalGreen.opacity(0.25), radius: 12)
                                        .padding(.vertical, 8)
                                },
                                placeholder: {
                                    HStack {
                                        Spacer()
                                        GalacticInlineSpinner(size: 40, lineWidth: 3)
                                            .padding(.vertical, 40)
                                        Spacer()
                                    }
                                },
                                errorView: {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "photo.slash")
                                            .font(.system(size: 48))
                                            .foregroundStyle(GalacticTheme.textSecondary)
                                        Spacer()
                                    }
                                }
                            )
                            .listRowBackground(background.cardColor)
                        }
                        
                        // Identity section
                        Section {
                            CharacterDetailsFormCell(key: "Name",     value: character.name)
                            CharacterDetailsFormCell(key: "Species",  value: character.species)
                            CharacterDetailsFormCell(key: "Type",     value: character.type)
                            CharacterDetailsFormCell(key: "Gender",   value: character.gender.presentationValue)
                            CharacterDetailsFormCell(key: "Origin",   value: character.origin.name)
                            CharacterDetailsFormCell(key: "Location", value: character.location.name)

                            HStack {
                                Text("Status")
                                    .font(.system(.subheadline, weight: .bold))
                                    .foregroundStyle(GalacticTheme.keyText)
                                Spacer()
                                StatusBadge(status: character.status)
                            }
                            .listRowBackground(background.cardColor)
                        } header: {
                            GalacticSectionHeader("Identity")
                        }
                        
                        // Episodes section
                        Section {
                            HStack {
                                Text("Total Episodes")
                                    .font(.system(.subheadline, weight: .bold))
                                    .foregroundStyle(GalacticTheme.keyText)
                                Spacer()
                                Text(character.episode.count.description)
                                    .font(.subheadline)
                                    .foregroundStyle(GalacticTheme.textSecondary)
                            }
                            .listRowBackground(background.cardColor)

                            ForEach(character.episode, id: \.self) { episode in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(GalacticTheme.portalGreen.opacity(0.6))
                                        .frame(width: 5, height: 5)
                                    Text(episode.lastPathComponent)
                                        .font(.system(.caption))
                                        .foregroundStyle(GalacticTheme.textSecondary)
                                }
                                .listRowBackground(background.cardColor)
                            }
                        } header: {
                            GalacticSectionHeader("Episodes")
                        }
                    }
                    .galacticList()
                    .listStyle(.insetGrouped)
                }
            }
        }
        .navigationTitle(Text("Character"))
        .galacticNavigationBar()
        .galacticSettingsToolbar()
        .navigationBarTitleDisplayMode(.inline)
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
    CharacterDetails(id: 1)
}
