//
//  Networking.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation

protocol Service {
    func getCharacterWith(id: Int) async throws -> Character
    func listCharacters(page: Int, name: String?, status: String?) async throws -> GetAllCharactersResponse
    func listLocations(page: Int, name: String?) async throws -> GetAllLocationsResponse
    func getLocationWith(id: Int) async throws -> Location
    func listEpisodes(page: Int, name: String?) async throws -> GetAllEpisodesResponse
    func getEpisodeWith(id: Int) async throws -> Episode
    func getCharactersByURLs(_ urls: [String]) async throws -> [Character]
}

struct ApiService: Service {
    
    // MARK: Properties
    
    private let baseUrl = "https://rickandmortyapi.com/api"
    
    private let urlSession: URLSession
    
    // MARK: Initializer
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    // MARK: Implementation
    
    func getCharacterWith(id: Int) async throws -> Character {
        guard let url = URL(string: baseUrl + "/character/\(id)") else {
            throw NetworkingError.badUrl
        }
        
        let (data, response) = try await urlSession.data(from: url)
        
        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            throw NetworkingError.request(response.statusCode)
        } else {
            return try JSONDecoder().decode(Character.self, from: data)
        }
    }
    
    func listCharacters(page: Int = 1, name: String?, status: String?) async throws -> GetAllCharactersResponse {
        
        let url = try characterUrlWith(page: page, name: name, status: status)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await urlSession.data(from: url)
        
        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            if response.statusCode == 404 {
                return GetAllCharactersResponse(info: GetAllCharactersResponse.Info(next: nil), results: [])
            } else {
                throw NetworkingError.request(response.statusCode)
            }
        } else {
            return try JSONDecoder().decode(GetAllCharactersResponse.self, from: data)            
        }
    }
    
    private func characterUrlWith(page: Int = 1, name: String?, status: String?) throws -> URL {
        guard var urlComponents = URLComponents(string: baseUrl + "/character") else {
            throw NetworkingError.badUrl
        }
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page))
        ]
        
        if let name {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }
        
        if let status {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw NetworkingError.badUrlComponents
        }
        
        return url
    }

    // MARK: Locations

    func listLocations(page: Int = 1, name: String?) async throws -> GetAllLocationsResponse {
        guard var urlComponents = URLComponents(string: baseUrl + "/location") else {
            throw NetworkingError.badUrl
        }

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page))
        ]

        if let name {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw NetworkingError.badUrlComponents
        }

        let (data, response) = try await urlSession.data(from: url)

        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            if response.statusCode == 404 {
                return GetAllLocationsResponse(info: GetAllLocationsResponse.Info(next: nil), results: [])
            } else {
                throw NetworkingError.request(response.statusCode)
            }
        } else {
            return try JSONDecoder().decode(GetAllLocationsResponse.self, from: data)
        }
    }

    func getLocationWith(id: Int) async throws -> Location {
        guard let url = URL(string: baseUrl + "/location/\(id)") else {
            throw NetworkingError.badUrl
        }

        let (data, response) = try await urlSession.data(from: url)

        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            throw NetworkingError.request(response.statusCode)
        } else {
            return try JSONDecoder().decode(Location.self, from: data)
        }
    }

    // MARK: Episodes

    func listEpisodes(page: Int = 1, name: String?) async throws -> GetAllEpisodesResponse {
        guard var urlComponents = URLComponents(string: baseUrl + "/episode") else {
            throw NetworkingError.badUrl
        }

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page))
        ]

        if let name {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw NetworkingError.badUrlComponents
        }

        let (data, response) = try await urlSession.data(from: url)

        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            if response.statusCode == 404 {
                return GetAllEpisodesResponse(info: GetAllEpisodesResponse.Info(next: nil), results: [])
            } else {
                throw NetworkingError.request(response.statusCode)
            }
        } else {
            return try JSONDecoder().decode(GetAllEpisodesResponse.self, from: data)
        }
    }

    func getEpisodeWith(id: Int) async throws -> Episode {
        guard let url = URL(string: baseUrl + "/episode/\(id)") else {
            throw NetworkingError.badUrl
        }

        let (data, response) = try await urlSession.data(from: url)

        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            throw NetworkingError.request(response.statusCode)
        } else {
            return try JSONDecoder().decode(Episode.self, from: data)
        }
    }

    // MARK: Multiple Characters by URLs

    /// The API accepts several ids in one path — `/character/1,2,3` — and returns
    /// them together. A location like the Citadel of Ricks lists 101 residents;
    /// requesting those one at a time got the app rate limited (HTTP 429), which
    /// surfaced as an error alert on every busy location and episode.
    ///
    /// 101 ids fit comfortably in one URL, but chunk anyway so an unusually long
    /// list cannot produce an over-long path.
    private static let charactersPerRequest = 100

    func getCharactersByURLs(_ urls: [String]) async throws -> [Character] {
        let ids = try urls.map(Self.characterId(fromURL:))

        guard !ids.isEmpty else { return [] }

        var characters: [Character] = []
        characters.reserveCapacity(ids.count)

        for start in stride(from: 0, to: ids.count, by: Self.charactersPerRequest) {
            let batch = Array(ids[start ..< min(start + Self.charactersPerRequest, ids.count)])
            characters.append(contentsOf: try await fetchCharacters(withIds: batch))
        }

        return characters.sorted { $0.id < $1.id }
    }

    /// Pulls the trailing id out of a character URL such as
    /// `https://rickandmortyapi.com/api/character/42`.
    private static func characterId(fromURL urlString: String) throws -> String {
        guard let id = urlString.split(separator: "/").last.map(String.init),
              !id.isEmpty,
              id.allSatisfy(\.isNumber) else {
            throw NetworkingError.badUrl
        }
        return id
    }

    private func fetchCharacters(withIds ids: [String]) async throws -> [Character] {
        guard let url = URL(string: baseUrl + "/character/" + ids.joined(separator: ",")) else {
            throw NetworkingError.badUrl
        }

        let (data, response) = try await urlSession.data(from: url)

        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            throw NetworkingError.request(response.statusCode)
        }

        // One id returns a single object; two or more return an array.
        if ids.count == 1 {
            return [try JSONDecoder().decode(Character.self, from: data)]
        }

        return try JSONDecoder().decode([Character].self, from: data)
    }
}
