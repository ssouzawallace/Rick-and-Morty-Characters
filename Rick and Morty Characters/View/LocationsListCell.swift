//
//  LocationsListCell.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct LocationsListCell: View {

    let location: Location

    var body: some View {
        GalacticRowLayout {
            GalacticIconTile(systemImage: "globe.americas.fill")
        } trailing: {
            GalacticInfoCard {
                Text(location.name)
                    .font(.system(.headline, weight: .bold))
                    .foregroundStyle(GalacticTheme.textPrimary)
                    .lineLimit(2)

                if !location.type.isEmpty {
                    GalacticCaption(systemImage: "mappin.and.ellipse", text: location.type)
                }

                if !location.dimension.isEmpty {
                    GalacticCaption(systemImage: "circle.hexagongrid.fill", text: location.dimension)
                }

                GalacticCaption(
                    systemImage: "person.2.fill",
                    text: "\(location.residents.count) residents"
                )
            }
        }
    }
}
