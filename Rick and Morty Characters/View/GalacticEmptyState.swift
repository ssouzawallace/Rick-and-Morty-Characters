//
//  GalacticEmptyState.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

/// The "no results" placeholder shared by all three tabs.
struct GalacticEmptyState: View {

    var systemImage: String = "magnifyingglass"
    var title: String = "No Results"

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(GalacticTheme.portalGreen)
            Text(title)
                .font(.title3)
                .foregroundStyle(GalacticTheme.textSecondary)
        }
    }
}
