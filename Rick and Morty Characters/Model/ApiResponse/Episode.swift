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

    enum CodingKeys: String, CodingKey {
        case id, name, episode, characters, url, created
        case airDate = "air_date"
    }

    static func == (lhs: Episode, rhs: Episode) -> Bool {
        lhs.id == rhs.id
    }
}

extension Episode {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)

        let airDateString = try container.decode(String.self, forKey: .airDate)
        self.airDate = airDateString.isEmpty ? "Unknown" : airDateString

        let episodeString = try container.decode(String.self, forKey: .episode)
        self.episode = episodeString.isEmpty ? "Unknown" : episodeString

        self.characters = try container.decode([String].self, forKey: .characters)
        self.url = try container.decode(String.self, forKey: .url)

        let createdString = try container.decode(String.self, forKey: .created)
        self.created = ISO8601DateFormatter().date(from: createdString) ?? nil
    }
}
