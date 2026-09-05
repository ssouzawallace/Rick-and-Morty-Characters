//
//  MockService.swift
//  Rick and Morty CharactersTests
//
//  Created by Wallace Souza Silva
//

import Foundation
@testable import Rick_and_Morty_Characters

/// A `Service` double whose every call returns a configurable `Result` and records what it was asked for.
///
/// Every result defaults to `.failure(NetworkingError.badUrl)` so a test that forgets to configure a
/// path it exercises fails loudly instead of returning a silently-fabricated value.
class MockService: Service {

    var getCharacterResult: Result<Character, Error> = .failure(NetworkingError.badUrl)
    var listCharactersResult: Result<GetAllCharactersResponse, Error> = .failure(NetworkingError.badUrl)
    var listLocationsResult: Result<GetAllLocationsResponse, Error> = .failure(NetworkingError.badUrl)
    var getLocationResult: Result<Location, Error> = .failure(NetworkingError.badUrl)
    var listEpisodesResult: Result<GetAllEpisodesResponse, Error> = .failure(NetworkingError.badUrl)
    var getEpisodeResult: Result<Episode, Error> = .failure(NetworkingError.badUrl)
    var getCharactersByURLsResult: Result<[Character], Error> = .failure(NetworkingError.badUrl)

    var getCharacterCallCount = 0
    var listCharactersCallCount = 0
    var listLocationsCallCount = 0
    var getLocationCallCount = 0
    var listEpisodesCallCount = 0
    var getEpisodeCallCount = 0
    var getCharactersByURLsCallCount = 0

    var lastRequestedId: Int?
    var lastRequestedPage: Int?
    var lastRequestedName: String?
    var lastRequestedStatus: String?
    var lastRequestedURLs: [String]?

    func getCharacterWith(id: Int) async throws -> Character {
        getCharacterCallCount += 1
        lastRequestedId = id
        return try getCharacterResult.get()
    }

    func listCharacters(page: Int, name: String?, status: String?) async throws -> GetAllCharactersResponse {
        listCharactersCallCount += 1
        lastRequestedPage = page
        lastRequestedName = name
        lastRequestedStatus = status
        return try listCharactersResult.get()
    }

    func listLocations(page: Int, name: String?) async throws -> GetAllLocationsResponse {
        listLocationsCallCount += 1
        lastRequestedPage = page
        lastRequestedName = name
        return try listLocationsResult.get()
    }

    func getLocationWith(id: Int) async throws -> Location {
        getLocationCallCount += 1
        lastRequestedId = id
        return try getLocationResult.get()
    }

    func listEpisodes(page: Int, name: String?) async throws -> GetAllEpisodesResponse {
        listEpisodesCallCount += 1
        lastRequestedPage = page
        lastRequestedName = name
        return try listEpisodesResult.get()
    }

    func getEpisodeWith(id: Int) async throws -> Episode {
        getEpisodeCallCount += 1
        lastRequestedId = id
        return try getEpisodeResult.get()
    }

    func getCharactersByURLs(_ urls: [String]) async throws -> [Character] {
        getCharactersByURLsCallCount += 1
        lastRequestedURLs = urls
        return try getCharactersByURLsResult.get()
    }
}
