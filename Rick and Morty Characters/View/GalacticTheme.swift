//
//  GalacticTheme.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

// MARK: - Galactic Colour Palette

enum GalacticTheme {

    // Backgrounds
    static let spaceBackground  = Color(red: 0.039, green: 0.063, blue: 0.118)   // #0A1030
    static let cardBackground   = Color(red: 0.102, green: 0.157, blue: 0.216)   // #1A2837
    static let sectionHeader    = Color(red: 0.055, green: 0.110, blue: 0.157)   // #0E1C28

    // Accent / Portal
    static let portalGreen      = Color(red: 0.592, green: 0.808, blue: 0.298)   // #97CE4C
    static let portalTeal       = Color(red: 0.153, green: 0.808, blue: 0.573)   // #27CE92
    static let galacticPurple   = Color(red: 0.404, green: 0.188, blue: 0.706)   // #673FB4

    // Text
    static let textPrimary      = Color.white
    static let textSecondary    = Color(white: 0.72)
    static let keyText          = portalGreen

    // UI chrome
    static let divider          = Color(white: 0.25)
    static let separatorList    = Color(white: 0.18)

    // MARK: Status indicator colour
    static func statusColor(for status: CharacterStatus) -> Color {
        switch status {
        case .alive:              return Color(red: 0.498, green: 0.843, blue: 0.196) // bright green
        case .dead:               return Color(red: 0.925, green: 0.302, blue: 0.302) // red
        case .unknown, .undefined: return Color(white: 0.55)
        }
    }
}

// MARK: - Reusable view modifiers

struct GalacticCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(GalacticTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(GalacticTheme.portalGreen.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: GalacticTheme.portalGreen.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func galacticCard() -> some View {
        modifier(GalacticCardModifier())
    }
}

// MARK: - Galactic loading view (full-screen)

struct GalacticLoadingView: View {

    var body: some View {
        ZStack {
            GalacticTheme.spaceBackground.ignoresSafeArea()

            VStack(spacing: 20) {
                GalacticInlineSpinner(size: 60, lineWidth: 4)

                Text("Loading…")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(GalacticTheme.textSecondary)
            }
        }
    }
}

// MARK: - Galactic inline spinner (for list rows / placeholders)

struct GalacticInlineSpinner: View {
    var size: CGFloat = 28
    var lineWidth: CGFloat = 3

    @State private var rotating = false

    var body: some View {
        Circle()
            .stroke(
                AngularGradient(
                    colors: [GalacticTheme.portalGreen, GalacticTheme.portalTeal, .clear],
                    center: .center
                ),
                lineWidth: lineWidth
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotating ? 360 : 0))
            .animation(.linear(duration: 0.9).repeatForever(autoreverses: false), value: rotating)
            .onAppear { rotating = true }
    }
}

// MARK: - Status badge

struct StatusBadge: View {
    let status: CharacterStatus

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(GalacticTheme.statusColor(for: status))
                .frame(width: 8, height: 8)
                .shadow(color: GalacticTheme.statusColor(for: status).opacity(0.8), radius: 4)

            Text(status == .undefined ? "Unknown" : status.presentationValue)
                .font(.caption)
                .foregroundStyle(GalacticTheme.statusColor(for: status))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(GalacticTheme.statusColor(for: status).opacity(0.12))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(GalacticTheme.statusColor(for: status).opacity(0.4), lineWidth: 0.5)
        )
    }
}

#Preview("Loading") {
    GalacticLoadingView()
}

#Preview("Status badges") {
    VStack(spacing: 12) {
        StatusBadge(status: .alive)
        StatusBadge(status: .dead)
        StatusBadge(status: .unknown)
    }
    .padding()
    .background(GalacticTheme.spaceBackground)
}
