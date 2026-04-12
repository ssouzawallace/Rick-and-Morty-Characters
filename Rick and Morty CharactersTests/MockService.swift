//
//  MockService.swift
//  Rick and Morty CharactersTests
//
//  Created by Copilot
//

import Foundation
@testable import Rick_and_Morty_Characters

class MockService: Service {
    
    var getCharacterResult: Result<Character, Error> = .failure(NetworkingError.badUrl)
    var listCharactersResult: Result<GetAllCharactersResponse, Error> = .failure(NetworkingError.badUrl)
    
    var getCharacterCallCount = 0
    var listCharactersCallCount = 0
    var lastRequestedId: Int?
    var lastRequestedPage: Int?
    var lastRequestedName: String?
    var lastRequestedStatus: String?
    
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
}
