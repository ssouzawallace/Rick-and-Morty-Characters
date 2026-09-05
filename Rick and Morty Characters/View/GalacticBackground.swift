//
//  GalacticBackground.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

/// The eight backgrounds a viewer can pick from, stored as a user preference and
/// read by every screen.
///
/// All eight are dark: the palette's text and portal colours are tuned for a dark
/// ground, and a light option would make `textPrimary` (white) unreadable.
enum GalacticBackground: String, CaseIterable, Identifiable {

    case deepSpace
    case portalSlime
    case citadelSteel
    case cronenbergMauve
    case squanchViolet
    case bloodRidge
    case meeseeksBlue
    case gazorpazorpGold

    /// UserDefaults key backing the preference. Shared so every `@AppStorage`
    /// declaration reads the same value.
    static let storageKey = "galacticBackground"

    static let `default`: GalacticBackground = .deepSpace

    var id: String { rawValue }

    var name: String {
        switch self {
        case .deepSpace:        return "Deep Space"
        case .portalSlime:      return "Portal Slime"
        case .citadelSteel:     return "Citadel Steel"
        case .cronenbergMauve:  return "Cronenberg Mauve"
        case .squanchViolet:    return "Squanch Violet"
        case .bloodRidge:       return "Blood Ridge"
        case .meeseeksBlue:     return "Meeseeks Blue"
        case .gazorpazorpGold:  return "Gazorpazorp Gold"
        }
    }

    var subtitle: String {
        switch self {
        case .deepSpace:        return "The original night sky"
        case .portalSlime:      return "Straight out of the portal gun"
        case .citadelSteel:     return "Cold bureaucracy of the Citadel"
        case .cronenbergMauve:  return "That dimension we had to leave"
        case .squanchViolet:    return "A real squanchy evening"
        case .bloodRidge:       return "Blood Ridge at dusk"
        case .meeseeksBlue:     return "Existence is pain, but tidy"
        case .gazorpazorpGold:  return "Sunset over Gazorpazorp"
        }
    }

    /// The screen background.
    var color: Color {
        switch self {
        case .deepSpace:        return Color(red: 0.039, green: 0.063, blue: 0.118) // #0A1030
        case .portalSlime:      return Color(red: 0.027, green: 0.102, blue: 0.055) // #071A0E
        case .citadelSteel:     return Color(red: 0.071, green: 0.090, blue: 0.110) // #12171C
        case .cronenbergMauve:  return Color(red: 0.118, green: 0.059, blue: 0.106) // #1E0F1B
        case .squanchViolet:    return Color(red: 0.082, green: 0.039, blue: 0.180) // #150A2E
        case .bloodRidge:       return Color(red: 0.125, green: 0.039, blue: 0.047) // #200A0C
        case .meeseeksBlue:     return Color(red: 0.024, green: 0.094, blue: 0.149) // #061826
        case .gazorpazorpGold:  return Color(red: 0.118, green: 0.086, blue: 0.020) // #1E1605
        }
    }

    /// The colour of the cards, tiles and form rows that sit on `color`.
    ///
    /// Each is the same hue lifted a few steps, so a card reads as raised off its
    /// own background rather than as a navy rectangle borrowed from another theme.
    var cardColor: Color {
        switch self {
        case .deepSpace:        return Color(red: 0.102, green: 0.157, blue: 0.216) // #1A2837
        case .portalSlime:      return Color(red: 0.071, green: 0.188, blue: 0.110) // #12301C
        case .citadelSteel:     return Color(red: 0.129, green: 0.161, blue: 0.196) // #212932
        case .cronenbergMauve:  return Color(red: 0.200, green: 0.110, blue: 0.180) // #331C2E
        case .squanchViolet:    return Color(red: 0.149, green: 0.094, blue: 0.278) // #261847
        case .bloodRidge:       return Color(red: 0.212, green: 0.086, blue: 0.098) // #361619
        case .meeseeksBlue:     return Color(red: 0.063, green: 0.169, blue: 0.243) // #102B3E
        case .gazorpazorpGold:  return Color(red: 0.196, green: 0.149, blue: 0.055) // #32260E
        }
    }
}

// MARK: - Reading the preference

/// Reads the stored background. `@AppStorage` is a `DynamicProperty`, so every
/// view that declares this redraws when the preference changes — no environment
/// object to thread through the whole hierarchy.
@propertyWrapper
struct GalacticBackgroundPreference: DynamicProperty {

    @AppStorage(GalacticBackground.storageKey)
    private var stored: GalacticBackground = GalacticBackground.default

    var wrappedValue: GalacticBackground {
        get { stored }
        nonmutating set { stored = newValue }
    }

    var projectedValue: Binding<GalacticBackground> { $stored }

    init() {}
}
