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

    /// A navigation bar that is clear at the top of a scroll and fades in over
    /// content as the list moves under it.
    func galacticNavigationBar() -> some View {
        modifier(GalacticNavigationBarModifier())
    }
}

// MARK: - Navigation bar

/// The bar was pinned transparent, which reads well at the top of a scroll and
/// badly once rows pass under the title. Supplying a background style instead of
/// hiding it lets the system keep its default behaviour: clear at the scroll
/// edge, drawn once the content scrolls.
///
/// The style is a gradient rather than a flat fill — opaque under the status bar
/// and title, fading to nothing at the bar's lower edge, so there is no hard seam
/// where the bar ends and the list begins.
private struct GalacticNavigationBarModifier: ViewModifier {

    @GalacticBackgroundPreference private var background

    func body(content: Content) -> some View {
        content
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(
                LinearGradient(
                    colors: [background.color, background.color.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                for: .navigationBar
            )
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
