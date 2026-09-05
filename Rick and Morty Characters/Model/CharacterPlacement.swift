//
//  CharacterPlacement.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation

struct CharacterPlacement: Codable {
    let name: String
    let url: String
}

extension CharacterPlacement {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Treat edge case for empty Species
        let nameString = try container.decode(String.self, forKey: .name)
        self.name = nameString.isEmpty ? "Unknown" : nameString
        
        self.url = try container.decode(String.self, forKey: .url)
    }
}
