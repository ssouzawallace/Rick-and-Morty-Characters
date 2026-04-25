//
//  Episode.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation

struct Episode: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
    let characters: [String]
    let url: String
    let created: Date?

    static func == (lhs: Episode, rhs: Episode) -> Bool {
        lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, name, episode, characters, url, created
        case airDate = "air_date"
    }
}

extension Episode {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)

        let nameString = try container.decode(String.self, forKey: .name)
        self.name = nameString.isEmpty ? "Unknown" : nameString

        self.airDate = try container.decode(String.self, forKey: .airDate)
        self.episode = try container.decode(String.self, forKey: .episode)
        self.characters = try container.decode([String].self, forKey: .characters)
        self.url = try container.decode(String.self, forKey: .url)

        let createdString = try container.decode(String.self, forKey: .created)
        self.created = ISO8601DateFormatter().date(from: createdString) ?? nil
    }
}
