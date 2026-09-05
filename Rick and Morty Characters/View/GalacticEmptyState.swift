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

    @GalacticBackgroundPreference private var background

    var body: some View {
        HStack {
            Spacer()
            GalacticInlineSpinner(size: 28, lineWidth: 3)
                .padding(.vertical, 12)
            Spacer()
        }
        .listRowBackground(background.color)
        .listRowSeparator(.hidden)
        .onAppear(perform: onAppear)
    }
}

// MARK: - Screen chrome

/// A `ViewModifier` rather than a plain `View` extension so it can hold the
/// `@AppStorage` preference and redraw when the viewer picks a new background.
private struct GalacticListModifier: ViewModifier {

    @GalacticBackgroundPreference private var background

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(background.color)
    }
}

extension View {

    /// Hides the system list background and paints the chosen one. The list
    /// style stays with the caller: plain for the tab lists, inset-grouped for
    /// the details forms.
    func galacticList() -> some View {
        modifier(GalacticListModifier())
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
