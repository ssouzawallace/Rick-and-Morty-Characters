//
//  GalacticPagingFooter.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

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
