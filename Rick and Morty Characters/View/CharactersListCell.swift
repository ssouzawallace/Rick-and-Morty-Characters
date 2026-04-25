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
        HStack(spacing: 0) {

            // Character portrait
            ZStack {
                AsyncImage(url: URL(string: character.image)) { phase in
                    if phase.error != nil {
                        NoImageView()
                    } else if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        ZStack {
                            GalacticTheme.cardBackground
                            GalacticLoadingSpinner()
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

            // Info panel
            VStack(alignment: .leading, spacing: 6) {
                Text(character.name)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(GalacticTheme.textPrimary)
                    .lineLimit(2)

                StatusBadge(status: character.status)

                HStack(spacing: 4) {
                    Image(systemName: "atom")
                        .font(.caption2)
                        .foregroundStyle(GalacticTheme.portalTeal)
                    Text(character.species)
                        .font(.caption)
                        .foregroundStyle(GalacticTheme.textSecondary)
                }
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .galacticCard()
        .listRowBackground(GalacticTheme.spaceBackground)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
    }
}

// Small inline spinner used inside cells
private struct GalacticLoadingSpinner: View {
    @State private var rotating = false

    var body: some View {
        Circle()
            .stroke(
                AngularGradient(
                    colors: [GalacticTheme.portalGreen, GalacticTheme.portalTeal, .clear],
                    center: .center
                ),
                lineWidth: 3
            )
            .frame(width: 28, height: 28)
            .rotationEffect(.degrees(rotating ? 360 : 0))
            .animation(.linear(duration: 0.9).repeatForever(autoreverses: false), value: rotating)
            .onAppear { rotating = true }
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
