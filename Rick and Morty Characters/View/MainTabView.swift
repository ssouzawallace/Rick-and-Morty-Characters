//
//  MainTabView.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct MainTabView: View {

    var body: some View {
        TabView {
            CharactersList()
                .tabItem {
                    Label("Characters", systemImage: "person.3.fill")
                }

            LocationsList()
                .tabItem {
                    Label("Locations", systemImage: "map.fill")
                }

            EpisodesList()
                .tabItem {
                    Label("Episodes", systemImage: "tv.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
