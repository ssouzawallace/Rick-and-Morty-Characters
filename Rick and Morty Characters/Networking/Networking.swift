//
//  Networking.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation

protocol Service {
    func getCharacterWith(id: Int) async throws  -> Character
    func listCharacters(page: Int, name: String?, status: String?) async throws -> GetAllCharactersResponse
}

struct ApiService: Service {
    
    // MARK: Properties
    
    let baseUrl = "https://rickandmortyapi.com/api"
    
    let urlSession: URLSession
    
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
            throw NetworkingError.request(response.statusCode)
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
}
