//
//  Rick_and_Morty_CharacterModelTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Copilot
//

import XCTest
@testable import Rick_and_Morty_Characters

final class Rick_and_Morty_CharacterModelTests: XCTestCase {

    // MARK: - Standard Decoding

    func testDecodeCharacterWithStandardFields() throws {
        let data = Data(singleCharacterJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)

        XCTAssertEqual(character.id, 1)
        XCTAssertEqual(character.name, "Rick Sanchez")
        XCTAssertEqual(character.status, .alive)
        XCTAssertEqual(character.species, "Human")
        XCTAssertEqual(character.gender, .male)
        XCTAssertEqual(character.origin.name, "Earth (C-137)")
        XCTAssertEqual(character.location.name, "Citadel of Ricks")
        XCTAssertEqual(character.image, "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
        XCTAssertEqual(character.episode.count, 1)
        XCTAssertEqual(character.url, "https://rickandmortyapi.com/api/character/1")
        XCTAssertNotNil(character.created)
    }

    // MARK: - Empty Fields Default to "Unknown"

    func testDecodeCharacterWithEmptySpeciesAndType() throws {
        let data = Data(characterWithEmptyFieldsJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)

        XCTAssertEqual(character.species, "Unknown", "Empty species should default to 'Unknown'")
        XCTAssertEqual(character.type, "Unknown", "Empty type should default to 'Unknown'")
    }

    func testDecodeCharacterWithNonEmptySpeciesAndType() throws {
        let data = Data(characterDeadFemaleJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)

        XCTAssertEqual(character.species, "Robot")
        XCTAssertEqual(character.type, "Mechanical")
    }

    // MARK: - Case-Insensitive Status Decoding

    func testDecodeStatusAlive() throws {
        let data = Data(singleCharacterJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)
        XCTAssertEqual(character.status, .alive)
    }

    func testDecodeStatusDead() throws {
        let data = Data(characterDeadFemaleJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)
        XCTAssertEqual(character.status, .dead)
    }

    func testDecodeStatusUnknown() throws {
        let data = Data(characterWithEmptyFieldsJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)
        XCTAssertEqual(character.status, .unknown)
    }

    func testDecodeUnrecognizedStatusFallsToUndefined() throws {
        let data = Data(characterWithUnknownEnumsJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)
        XCTAssertEqual(character.status, .undefined, "Unrecognized status should map to .undefined")
    }

    // MARK: - Case-Insensitive Gender Decoding

    func testDecodeGenderMale() throws {
        let data = Data(singleCharacterJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)
        XCTAssertEqual(character.gender, .male)
    }

    func testDecodeGenderFemale() throws {
        let data = Data(characterDeadFemaleJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)
        XCTAssertEqual(character.gender, .female)
    }

    func testDecodeGenderGenderless() throws {
        let data = Data(characterWithEmptyFieldsJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)
        XCTAssertEqual(character.gender, .genderless)
    }

    func testDecodeUnrecognizedGenderFallsToUndefined() throws {
        let data = Data(characterWithUnknownEnumsJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)
        XCTAssertEqual(character.gender, .undefined, "Unrecognized gender should map to .undefined")
    }

    // MARK: - Date Parsing

    func testDecodeValidDate() throws {
        let data = Data(singleCharacterJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)
        XCTAssertNotNil(character.created, "Valid ISO8601 date should be parsed")
    }

    func testDecodeInvalidDateReturnsNil() throws {
        let data = Data(characterWithUnknownEnumsJson.utf8)
        let character = try JSONDecoder().decode(Character.self, from: data)
        XCTAssertNil(character.created, "Invalid date string should result in nil")
    }

    // MARK: - Equatable

    func testEquatableByIdOnly() throws {
        let data1 = Data(singleCharacterJson.utf8)
        let character1 = try JSONDecoder().decode(Character.self, from: data1)

        // Decode the same JSON again — same id means equal
        let character2 = try JSONDecoder().decode(Character.self, from: data1)
        XCTAssertEqual(character1, character2)
    }

    func testNotEqualWithDifferentIds() throws {
        let data1 = Data(singleCharacterJson.utf8)
        let character1 = try JSONDecoder().decode(Character.self, from: data1)

        let data2 = Data(characterDeadFemaleJson.utf8)
        let character2 = try JSONDecoder().decode(Character.self, from: data2)

        XCTAssertNotEqual(character1, character2)
    }
}
