//
//  CharactersListCell.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct CharactersListCell: View {

    private struct NoImageView: View {

        @GalacticBackgroundPreference private var background

        var body: some View {
            ZStack {
                Rectangle()
                    .fill(background.cardColor)

                VStack(spacing: 6) {
                    Image(systemName: "photo.slash")
                        .font(.system(size: 32))
                        .foregroundStyle(GalacticTheme.textSecondary)
                    Text("No Image")
                        .font(.caption)
                        .foregroundStyle(GalacticTheme.textSecondary)
                }
            }
        }
    }

    let character: Character

    @GalacticBackgroundPreference private var background

    var body: some View {
        GalacticRowLayout {
            GalacticTile {
                CachedAsyncImage(
                    url: URL(string: character.image),
                    content: { image in
                        image.resizable().scaledToFill()
                    },
                    placeholder: {
                        ZStack {
                            background.cardColor
                            GalacticInlineSpinner()
                        }
                    },
                    errorView: {
                        NoImageView()
                    }
                )
            }
        } trailing: {
            GalacticInfoCard {
                Text(character.name)
                    .font(.system(.headline, weight: .bold))
                    .foregroundStyle(GalacticTheme.textPrimary)
                    .lineLimit(2)

                StatusBadge(status: character.status)

                GalacticCaption(systemImage: "atom", text: character.species)
            }
        }
    }
}

#Preview {
    List {
        CharactersListCell(
            character: Character(
                id: 1,
                name: "One True Rick Sanchez",
                status: .alive,
                species: "Human",
                type: "Some Type",
                gender: .male,
                origin: CharacterPlacement(name: "Earth", url: ""),
                location: CharacterPlacement(name: "Somewhere", url: ""),
                image: "Zhttps://rickandmortyapi.com/api/character/avatar/1.jpeg",
                episode: [],
                url: "",
                created: nil
            )
        )
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(GalacticTheme.spaceBackground)
}
