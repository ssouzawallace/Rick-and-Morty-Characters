//
//  Character.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation

struct Character: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let type: String
    let gender: CharacterGender
    let origin: CharacterPlacement
    let location: CharacterPlacement
    let image: String
    let episode: [String]
    let url: String
    let created: Date?
    
    static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.id == rhs.id
    }
}

extension Character {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        // Treat case sensitive Status
        let statusString = try container.decode(String.self, forKey: .status).lowercased()
        self.status = CharacterStatus(rawValue: statusString) ?? .undefined
        
        // Treat edge case for empty Species
        let speciesString = try container.decode(String.self, forKey: .species)
        self.species = speciesString.isEmpty ? "Unknown" : speciesString
        
        // Treat edge case for empty Type
        let typeString = try container.decode(String.self, forKey: .type)
        self.type = typeString.isEmpty ? "Unknown" : typeString
        
        // Treat case sensitive Gender
        let genderString = try container.decode(String.self, forKey: .gender).lowercased()
        self.gender = CharacterGender(rawValue: genderString) ?? .undefined
        
        self.origin = try container.decode(CharacterPlacement.self, forKey: .origin)
        self.location = try container.decode(CharacterPlacement.self, forKey: .location)
        self.image = try container.decode(String.self, forKey: .image)
        self.episode = try container.decode([String].self, forKey: .episode)
        self.url = try container.decode(String.self, forKey: .url)
        
        let createdString = try container.decode(String.self, forKey: .created)
        self.created = ISO8601DateFormatter().date(from: createdString) ?? nil
    }
}

