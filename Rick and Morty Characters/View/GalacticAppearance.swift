//
//  GalacticAppearance.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI
import UIKit

/// UIKit-backed chrome that SwiftUI modifiers cannot reach: the transparent
/// navigation bar, the tab bar tint, and the status picker's segmented control.
///
/// Applied once from the app entry point.
enum GalacticAppearance {

    static func apply() {
        applyNavigationBar()
        applyTabBar()
        applySegmentedControl()
    }

    /// Transparent, so the galactic background runs edge to edge behind the title.
    private static func applyNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(GalacticTheme.textPrimary)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(GalacticTheme.textPrimary)
        ]

        let navigationBar = UINavigationBar.appearance()
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.tintColor = UIColor(GalacticTheme.portalGreen)
    }

    /// Opaque, unlike the navigation bar: rows scrolling underneath a translucent
    /// tab bar make the selected item hard to read.
    private static func applyTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(GalacticTheme.sectionHeader)

        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    /// The default segmented control renders dark grey on dark blue, which is
    /// effectively invisible against the galactic background.
    private static func applySegmentedControl() {
        let control = UISegmentedControl.appearance()
        // UIAppearance is applied once at launch, so this cannot track the
        // chosen background. A translucent fill sits correctly on all eight.
        control.backgroundColor = UIColor(white: 1, alpha: 0.10)
        control.selectedSegmentTintColor = UIColor(GalacticTheme.portalGreen)
        control.setTitleTextAttributes(
            [
                .foregroundColor: UIColor(GalacticTheme.textPrimary),
                .font: UIFont.systemFont(ofSize: 13, weight: .medium)
            ],
            for: .normal
        )
        control.setTitleTextAttributes(
            [
                .foregroundColor: UIColor(GalacticTheme.spaceBackground),
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
            ],
            for: .selected
        )
    }
}
