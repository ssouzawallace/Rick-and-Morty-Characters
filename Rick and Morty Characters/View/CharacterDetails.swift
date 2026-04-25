//
//  CharacterDetails.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct CharacterDetails: View {
    
    @ObservedObject private var viewModel: CharactersDetailsViewModel
    
    init(id: Int) {
        viewModel = CharactersDetailsViewModel(id: id)
    }
    
    var body: some View {
        ZStack {
            GalacticTheme.spaceBackground.ignoresSafeArea()

            Group {
                switch viewModel.status {
                case .loading:
                    GalacticLoadingView()
                case .loaded(character: let character):
                    List {
                        // Portrait section
                        Section {
                            AsyncImage(url: URL(string: character.image)) { phase in
                                if let image = phase.image {
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
                                } else if phase.error != nil {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "photo.slash")
                                            .font(.system(size: 48))
                                            .foregroundStyle(GalacticTheme.textSecondary)
                                        Spacer()
                                    }
                                } else {
                                    HStack {
                                        Spacer()
                                        GalacticInlineSpinner(size: 40, lineWidth: 3)
                                            .padding(.vertical, 40)
                                        Spacer()
                                    }
                                }
                            }
                            .listRowBackground(GalacticTheme.spaceBackground)
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
                                    .font(.system(.subheadline, design: .monospaced, weight: .bold))
                                    .foregroundStyle(GalacticTheme.keyText)
                                Spacer()
                                StatusBadge(status: character.status)
                            }
                            .listRowBackground(GalacticTheme.cardBackground)
                        } header: {
                            Text("Identity")
                                .font(.system(.caption, design: .monospaced, weight: .semibold))
                                .foregroundStyle(GalacticTheme.portalTeal)
                                .textCase(nil)
                        }
                        
                        // Episodes section
                        Section {
                            HStack {
                                Text("Total Episodes")
                                    .font(.system(.subheadline, design: .monospaced, weight: .bold))
                                    .foregroundStyle(GalacticTheme.keyText)
                                Spacer()
                                Text(character.episode.count.description)
                                    .font(.subheadline)
                                    .foregroundStyle(GalacticTheme.textSecondary)
                            }
                            .listRowBackground(GalacticTheme.cardBackground)

                            ForEach(character.episode, id: \.self) { episode in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(GalacticTheme.portalGreen.opacity(0.6))
                                        .frame(width: 5, height: 5)
                                    Text(episode.lastPathComponent)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundStyle(GalacticTheme.textSecondary)
                                }
                                .listRowBackground(GalacticTheme.cardBackground)
                            }
                        } header: {
                            Text("Episodes")
                                .font(.system(.caption, design: .monospaced, weight: .semibold))
                                .foregroundStyle(GalacticTheme.portalTeal)
                                .textCase(nil)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(GalacticTheme.spaceBackground)
                    .listStyle(.insetGrouped)
                }
            }
        }
        .navigationTitle(Text("Character"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(GalacticTheme.sectionHeader, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
