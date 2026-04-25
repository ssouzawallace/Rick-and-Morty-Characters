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

    func getCharactersByURLs(_ urls: [String]) async throws -> [Character] {
        try await withThrowingTaskGroup(of: Character.self) { group in
            for urlString in urls {
                group.addTask {
                    guard let url = URL(string: urlString) else {
                        throw NetworkingError.badUrl
                    }
                    let (data, response) = try await self.urlSession.data(from: url)
                    if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                        throw NetworkingError.request(response.statusCode)
                    }
                    return try JSONDecoder().decode(Character.self, from: data)
                }
            }
            var characters: [Character] = []
            for try await character in group {
                characters.append(character)
            }
            return characters.sorted { $0.id < $1.id }
        }
    }
}
