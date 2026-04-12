//
//  Rick_and_Morty_CharacterPlacementTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Copilot
//

import XCTest
@testable import Rick_and_Morty_Characters

final class Rick_and_Morty_CharacterPlacementTests: XCTestCase {

    func testDecodePlacementWithValidName() throws {
        let json = """
        {"name":"Earth (C-137)","url":"https://rickandmortyapi.com/api/location/1"}
        """
        let data = Data(json.utf8)
        let placement = try JSONDecoder().decode(CharacterPlacement.self, from: data)

        XCTAssertEqual(placement.name, "Earth (C-137)")
        XCTAssertEqual(placement.url, "https://rickandmortyapi.com/api/location/1")
    }

    func testDecodePlacementWithEmptyNameDefaultsToUnknown() throws {
        let json = """
        {"name":"","url":""}
        """
        let data = Data(json.utf8)
        let placement = try JSONDecoder().decode(CharacterPlacement.self, from: data)

        XCTAssertEqual(placement.name, "Unknown", "Empty name should default to 'Unknown'")
        XCTAssertEqual(placement.url, "")
    }

    func testDecodePlacementFromCharacterOrigin() throws {
        let data = Data(characterWithEmptyFieldsJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)

        XCTAssertEqual(character.origin.name, "Unknown", "Empty origin name should default to 'Unknown'")
        XCTAssertEqual(character.location.name, "Unknown", "Empty location name should default to 'Unknown'")
    }

    func testDecodePlacementFromCharacterWithValidNames() throws {
        let data = Data(singleCharacterJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)

        XCTAssertEqual(character.origin.name, "Earth (C-137)")
        XCTAssertEqual(character.location.name, "Citadel of Ricks")
    }
}
