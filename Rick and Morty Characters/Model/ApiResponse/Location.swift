//
//  Location.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation

struct Location: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residents: [String]
    let url: String
    let created: Date?

    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}

extension Location {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)

        let nameString = try container.decode(String.self, forKey: .name)
        self.name = nameString.isEmpty ? "Unknown" : nameString

        let typeString = try container.decode(String.self, forKey: .type)
        self.type = typeString.isEmpty ? "Unknown" : typeString

        let dimensionString = try container.decode(String.self, forKey: .dimension)
        self.dimension = dimensionString.isEmpty ? "Unknown" : dimensionString

        self.residents = try container.decode([String].self, forKey: .residents)
        self.url = try container.decode(String.self, forKey: .url)

        let createdString = try container.decode(String.self, forKey: .created)
        self.created = ISO8601DateFormatter().date(from: createdString)
    }
}
