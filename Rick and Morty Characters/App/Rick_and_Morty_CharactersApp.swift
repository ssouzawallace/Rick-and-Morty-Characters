//
//  Rick_and_Morty_CharactersApp.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

@main
struct Rick_and_Morty_CharactersApp: App {

    init() {
        GalacticAppearance.apply()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
