//
//  EpisodesListCell.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct EpisodesListCell: View {

    let episode: Episode

    var body: some View {
        GalacticRowLayout {
            GalacticIconTile(systemImage: "tv.fill")
        } trailing: {
            GalacticInfoCard {
                Text(episode.name)
                    .font(.system(.headline, weight: .bold))
                    .foregroundStyle(GalacticTheme.textPrimary)
                    .lineLimit(2)

                Text(episode.episode)
                    .font(.system(.caption, weight: .semibold))
                    .foregroundStyle(GalacticTheme.spaceBackground)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(GalacticTheme.portalGreen)
                    .clipShape(Capsule())

                GalacticCaption(systemImage: "calendar", text: episode.airDate)

                GalacticCaption(
                    systemImage: "person.2.fill",
                    text: "\(episode.characters.count) characters"
                )
            }
        }
    }
}
