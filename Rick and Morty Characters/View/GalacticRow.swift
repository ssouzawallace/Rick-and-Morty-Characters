//
//  GalacticRow.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

// MARK: - Row metrics

/// Shared geometry for the list rows on all three tabs, so a character, a
/// location and an episode line up identically.
enum GalacticRow {
    static let leadingSize: CGFloat = 100
    static let cornerRadius: CGFloat = 10
    static let spacing: CGFloat = 12
}

// MARK: - Leading tile

/// The square at the leading edge of a row: a character portrait, or an icon
/// for rows that have no artwork.
///
/// It has a minimum height rather than a fixed one, and stretches to whatever
/// the row ends up being, so the tile and the info card are always the same
/// height whichever of the two is taller.
struct GalacticTile<Content: View>: View {

    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            content()
        }
        .frame(width: GalacticRow.leadingSize)
        .frame(minHeight: GalacticRow.leadingSize, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: GalacticRow.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: GalacticRow.cornerRadius)
                .stroke(GalacticTheme.portalGreen.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: GalacticTheme.portalGreen.opacity(0.2), radius: 6, x: 0, y: 3)
    }
}

/// A `GalacticTile` holding an SF Symbol, for locations and episodes.
struct GalacticIconTile: View {

    let systemImage: String

    var body: some View {
        GalacticTile {
            GalacticTheme.cardBackground

            Image(systemName: systemImage)
                .font(.system(size: 38))
                .foregroundStyle(GalacticTheme.portalGreen)
                .shadow(color: GalacticTheme.portalGreen.opacity(0.5), radius: 8)
        }
    }
}

// MARK: - Info card

/// The floating card at the trailing edge of a row. Stretches to the row height
/// so it never sits shorter than the tile beside it.
struct GalacticInfoCard<Content: View>: View {

    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            content()
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(GalacticTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: GalacticRow.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: GalacticRow.cornerRadius)
                .stroke(GalacticTheme.portalGreen.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: GalacticTheme.portalGreen.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Row container

/// Lays a tile and an info card side by side at equal height, and applies the
/// list-row chrome every tab shares.
struct GalacticRowLayout<Leading: View, Trailing: View>: View {

    @ViewBuilder let leading: () -> Leading
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: GalacticRow.spacing) {
            leading()
            trailing()
        }
        // Height is the taller of the two, and both stretch to meet it.
        .fixedSize(horizontal: false, vertical: true)
        .padding(10)
    }
}

// MARK: - List row chrome

/// Applied to the row itself — a `NavigationLink` in the list — rather than
/// inside the cell. `listRowBackground` and `listRowSeparator` set on a nested
/// view do not reach the enclosing row, which left the system background
/// showing between cards.
private struct GalacticListRowModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .listRowBackground(GalacticTheme.spaceBackground)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
    }
}

extension View {

    /// The galactic list-row treatment: themed background, no separator, and the
    /// insets the cards are designed around.
    func galacticListRow() -> some View {
        modifier(GalacticListRowModifier())
    }
}

// MARK: - Caption row

/// A small icon-and-text line used inside info cards.
struct GalacticCaption: View {

    let systemImage: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.caption2)
                .foregroundStyle(GalacticTheme.portalTeal)
            Text(text)
                .font(.system(.caption, weight: .medium))
                .foregroundStyle(GalacticTheme.textSecondary)
                .lineLimit(2)
        }
    }
}
