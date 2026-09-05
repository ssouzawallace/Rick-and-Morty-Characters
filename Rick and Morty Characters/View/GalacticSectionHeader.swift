//
//  GalacticSectionHeader.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

/// The teal section caption used across the three details screens.
struct GalacticSectionHeader: View {

    private let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.system(.caption, weight: .semibold))
            .foregroundStyle(GalacticTheme.portalTeal)
            .textCase(nil)
    }
}
