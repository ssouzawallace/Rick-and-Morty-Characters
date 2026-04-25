//
//  CharactersListCell.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct CharactersListCell: View {
    
    private struct NoImageView: View {

        var body: some View {
            ZStack {
                Rectangle()
                    .fill(GalacticTheme.cardBackground)
                
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
    
    var body: some View {
        HStack(spacing: 12) {

            // Character portrait
            ZStack {
                AsyncImage(url: URL(string: character.image)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else if phase.error != nil {
                        NoImageView()
                    } else {
                        ZStack {
                            GalacticTheme.cardBackground
                            GalacticInlineSpinner()
                        }
                    }
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(GalacticTheme.portalGreen.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: GalacticTheme.portalGreen.opacity(0.2), radius: 6, x: 0, y: 3)

            // Info panel – floating card detached from the portrait
            VStack(alignment: .leading, spacing: 6) {
                Text(character.name)
                    .font(.system(.headline, weight: .bold))
                    .foregroundStyle(GalacticTheme.textPrimary)
                    .lineLimit(2)

                StatusBadge(status: character.status)

                HStack(spacing: 4) {
                    Image(systemName: "atom")
                        .font(.caption2)
                        .foregroundStyle(GalacticTheme.portalTeal)
                    Text(character.species)
                        .font(.system(.caption, weight: .medium))
                        .foregroundStyle(GalacticTheme.textSecondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GalacticTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(GalacticTheme.portalGreen.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: GalacticTheme.portalGreen.opacity(0.12), radius: 8, x: 0, y: 4)
        }
        .padding(10)
        .background(GalacticTheme.spaceBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .listRowBackground(GalacticTheme.spaceBackground)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
    }
}


#Preview {
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
