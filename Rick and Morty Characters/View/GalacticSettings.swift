//
//  GalacticSettings.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

/// The background picker, presented from the gear button on every screen.
struct GalacticSettings: View {

    @GalacticBackgroundPreference private var background

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                background.color.ignoresSafeArea()

                List {
                    Section {
                        ForEach(GalacticBackground.allCases) { option in
                            Button {
                                $background.wrappedValue = option
                            } label: {
                                row(for: option)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(background.cardColor)
                        }
                    } header: {
                        GalacticSectionHeader("Background")
                    } footer: {
                        Text("Applies to every screen.")
                            .font(.caption)
                            .foregroundStyle(GalacticTheme.textSecondary)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(background.color)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .galacticNavigationBar()
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(GalacticTheme.portalGreen)
                }
            }
        }
    }

    private func row(for option: GalacticBackground) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(option.color)
                .frame(width: 44, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(GalacticTheme.portalGreen.opacity(0.45), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(option.name)
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(GalacticTheme.textPrimary)
                Text(option.subtitle)
                    .font(.caption)
                    .foregroundStyle(GalacticTheme.textSecondary)
            }

            Spacer()

            if option == background {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(GalacticTheme.portalGreen)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(option == background ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - Toolbar entry point

private struct GalacticSettingsToolbar: ViewModifier {

    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .tint(GalacticTheme.portalGreen)
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $isPresented) {
                GalacticSettings()
            }
    }
}

extension View {

    /// Adds the gear button that opens the background picker. Every screen has it.
    func galacticSettingsToolbar() -> some View {
        modifier(GalacticSettingsToolbar())
    }
}

#Preview {
    GalacticSettings()
}
