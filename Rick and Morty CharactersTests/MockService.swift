//
//  MockService.swift
//  Rick and Morty CharactersTests
//
//  Created by Wallace Souza Silva
//

import Foundation
@testable import Rick_and_Morty_Characters

struct MockService: Service {
    var characterResult: Result<Character, Error>
    var listResult: Result<GetAllCharactersResponse, Error>

    init(
        characterResult: Result<Character, Error> = .success(testCharacter),
        listResult: Result<GetAllCharactersResponse, Error> = .success(testListResponse)
    ) {
        self.characterResult = characterResult
        self.listResult = listResult
    }

    func getCharacterWith(id: Int) async throws -> Character {
        try characterResult.get()
    }

    func listCharacters(page: Int, name: String?, status: String?) async throws -> GetAllCharactersResponse {
        try listResult.get()
    }
}

// MARK: - Shared Test Fixtures

var testCharacter: Character {
    // swiftlint:disable:next force_try
    try! JSONDecoder().decode(Character.self, from: singleCharacterJson.data(using: .utf8)!)
}

var testListResponse: GetAllCharactersResponse {
    GetAllCharactersResponse(
        info: GetAllCharactersResponse.Info(next: "https://rickandmortyapi.com/api/character?page=2"),
        results: [testCharacter]
    )
}

var singleCharacterJson: String {
    """
    {
        "id": 1,
        "name": "Rick Sanchez",
        "status": "Alive",
        "species": "Human",
        "type": "",
        "gender": "Male",
        "origin": {
            "name": "Earth (C-137)",
            "url": "https://rickandmortyapi.com/api/location/1"
        },
        "location": {
            "name": "Citadel of Ricks",
            "url": "https://rickandmortyapi.com/api/location/3"
        },
        "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
        "episode": ["https://rickandmortyapi.com/api/episode/1"],
        "url": "https://rickandmortyapi.com/api/character/1",
        "created": "2017-11-04T18:48:46.250Z"
    }
    """
}
