//
//  SwiftUIView.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

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

// MARK: - Navigation bar

/// Shared navigation bar modifier.
private struct GalacticNavigationBarModifier: ViewModifier {

    @GalacticBackgroundPreference private var background

    func body(content: Content) -> some View {
        content
    }
}
