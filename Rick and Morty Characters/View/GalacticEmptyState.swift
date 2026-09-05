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

/// The infinite-scroll footer shared by all three tabs.
struct GalacticPagingFooter: View {

    let onAppear: () -> Void

    var body: some View {
        HStack {
            Spacer()
            GalacticInlineSpinner(size: 28, lineWidth: 3)
                .padding(.vertical, 12)
            Spacer()
        }
        .listRowBackground(GalacticTheme.spaceBackground)
        .listRowSeparator(.hidden)
        .onAppear(perform: onAppear)
    }
}

// MARK: - Screen chrome

extension View {

    /// The galactic list treatment: hide the system list background, paint the
    /// galactic one, and leave the navigation bar transparent so it shows through.
    func galacticList() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(GalacticTheme.spaceBackground)
    }

    /// A transparent navigation bar over the galactic background.
    func galacticNavigationBar() -> some View {
        self
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
    }
}

// MARK: - Section header

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
