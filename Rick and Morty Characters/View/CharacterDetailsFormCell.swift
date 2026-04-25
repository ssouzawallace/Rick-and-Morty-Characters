//
//  CharacterDetailsFormCell.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import SwiftUI

struct CharacterDetailsFormCell: View {
    let key: String
    let value: String
    
    var body: some View {
        HStack {
            Text(key)
                .font(.system(.subheadline, design: .monospaced, weight: .bold))
                .foregroundStyle(GalacticTheme.keyText)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(GalacticTheme.textSecondary)
                .multilineTextAlignment(.trailing)
        }
        .listRowBackground(GalacticTheme.cardBackground)
    }
}

#Preview {
    CharacterDetailsFormCell(key: "Key", value: "Value")
}
