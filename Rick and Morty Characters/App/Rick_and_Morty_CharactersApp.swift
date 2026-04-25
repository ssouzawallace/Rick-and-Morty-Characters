//
//  Rick_and_Morty_CharactersApp.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

@main
struct Rick_and_Morty_CharactersApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                CharactersList()
                    .tabItem {
                        Label("Characters", systemImage: "person.2")
                    }
                EpisodesList()
                    .tabItem {
                        Label("Episodes", systemImage: "tv")
                    }
                LocationsList()
                    .tabItem {
                        Label("Locations", systemImage: "map")
                    }
            }
        }
    }
}
