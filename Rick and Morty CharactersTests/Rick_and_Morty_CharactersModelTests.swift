//
//  Rick_and_Morty_CharactersModelTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Wallace Souza Silva
//

import XCTest
@testable import Rick_and_Morty_Characters

final class Rick_and_Morty_CharactersModelTests: XCTestCase {

    // MARK: - Character Decoding

    func testCharacterDecodingSuccess() throws {
        let character = try JSONDecoder().decode(Character.self, from: singleCharacterJson.data(using: .utf8)!)
        XCTAssertEqual(character.id, 1)
        XCTAssertEqual(character.name, "Rick Sanchez")
        XCTAssertEqual(character.status, .alive)
        XCTAssertEqual(character.species, "Human")
        XCTAssertEqual(character.type, "Unknown") // empty string in JSON is mapped to "Unknown"
        XCTAssertEqual(character.gender, .male)
        XCTAssertEqual(character.origin.name, "Earth (C-137)")
        XCTAssertEqual(character.location.name, "Citadel of Ricks")
        XCTAssertNotNil(character.created)
    }

    func testCharacterDecodingEmptyTypeBecomesUnknown() throws {
        let character = try JSONDecoder().decode(Character.self, from: characterJsonWith(type: "").data(using: .utf8)!)
        XCTAssertEqual(character.type, "Unknown")
    }

    func testCharacterDecodingNonEmptyTypeIsPreserved() throws {
        let character = try JSONDecoder().decode(Character.self, from: characterJsonWith(type: "Parasite").data(using: .utf8)!)
        XCTAssertEqual(character.type, "Parasite")
    }

    func testCharacterDecodingEmptySpeciesBecomesUnknown() throws {
        let character = try JSONDecoder().decode(Character.self, from: characterJsonWith(species: "").data(using: .utf8)!)
        XCTAssertEqual(character.species, "Unknown")
    }

    func testCharacterDecodingUnknownStatusBecomesUndefined() throws {
        let character = try JSONDecoder().decode(Character.self, from: characterJsonWith(status: "SomeRandomStatus").data(using: .utf8)!)
        XCTAssertEqual(character.status, .undefined)
    }

    func testCharacterDecodingStatusIsCaseInsensitive() throws {
        let character = try JSONDecoder().decode(Character.self, from: characterJsonWith(status: "ALIVE").data(using: .utf8)!)
        XCTAssertEqual(character.status, .alive)
    }

    func testCharacterDecodingDeadStatus() throws {
        let character = try JSONDecoder().decode(Character.self, from: characterJsonWith(status: "Dead").data(using: .utf8)!)
        XCTAssertEqual(character.status, .dead)
    }

    func testCharacterDecodingUnknownGenderBecomesUndefined() throws {
        let character = try JSONDecoder().decode(Character.self, from: characterJsonWith(gender: "Nonbinary").data(using: .utf8)!)
        XCTAssertEqual(character.gender, .undefined)
    }

    func testCharacterDecodingGenderIsCaseInsensitive() throws {
        let character = try JSONDecoder().decode(Character.self, from: characterJsonWith(gender: "FEMALE").data(using: .utf8)!)
        XCTAssertEqual(character.gender, .female)
    }

    func testCharacterDecodingGenderlessGender() throws {
        let character = try JSONDecoder().decode(Character.self, from: characterJsonWith(gender: "Genderless").data(using: .utf8)!)
        XCTAssertEqual(character.gender, .genderless)
    }

    func testCharacterDecodingInvalidDateBecomesNil() throws {
        let character = try JSONDecoder().decode(Character.self, from: characterJsonWith(created: "not-a-date").data(using: .utf8)!)
        XCTAssertNil(character.created)
    }

    func testCharacterDecodingValidDateIsParsed() throws {
        let character = try JSONDecoder().decode(Character.self, from: characterJsonWith(created: "2017-11-04T18:48:46.250Z").data(using: .utf8)!)
        XCTAssertNotNil(character.created)
    }

    // MARK: - CharacterPlacement Decoding

    func testCharacterPlacementEmptyNameBecomesUnknown() throws {
        let json = #"{"name": "", "url": "https://example.com"}"#
        let placement = try JSONDecoder().decode(CharacterPlacement.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(placement.name, "Unknown")
    }

    func testCharacterPlacementNonEmptyNameIsPreserved() throws {
        let json = #"{"name": "Earth (C-137)", "url": "https://example.com"}"#
        let placement = try JSONDecoder().decode(CharacterPlacement.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(placement.name, "Earth (C-137)")
    }

    // MARK: - Presentable (CharacterStatus)

    func testCharacterStatusPresentationValues() {
        XCTAssertEqual(CharacterStatus.alive.presentationValue, "Alive")
        XCTAssertEqual(CharacterStatus.dead.presentationValue, "Dead")
        XCTAssertEqual(CharacterStatus.unknown.presentationValue, "Unknown")
        XCTAssertEqual(CharacterStatus.undefined.presentationValue, "Undefined")
    }

    // MARK: - Presentable (CharacterGender)

    func testCharacterGenderPresentationValues() {
        XCTAssertEqual(CharacterGender.male.presentationValue, "Male")
        XCTAssertEqual(CharacterGender.female.presentationValue, "Female")
        XCTAssertEqual(CharacterGender.genderless.presentationValue, "Genderless")
        XCTAssertEqual(CharacterGender.unknown.presentationValue, "Unknown")
        XCTAssertEqual(CharacterGender.undefined.presentationValue, "Undefined")
    }

    // MARK: - Character Equatable

    func testCharacterEqualityBasedOnId() throws {
        let char1 = try JSONDecoder().decode(Character.self, from: singleCharacterJson.data(using: .utf8)!)
        // Same id=1 but different name
        let char2 = try JSONDecoder().decode(Character.self, from: characterJsonWith(name: "Alternate Rick").data(using: .utf8)!)
        XCTAssertEqual(char1, char2)
    }

    func testCharacterInequalityForDifferentIds() throws {
        let char1 = try JSONDecoder().decode(Character.self, from: singleCharacterJson.data(using: .utf8)!)
        let char2 = try JSONDecoder().decode(Character.self, from: characterJsonWith(id: 2).data(using: .utf8)!)
        XCTAssertNotEqual(char1, char2)
    }
}

// MARK: - Helpers

private func characterJsonWith(
    id: Int = 1,
    name: String = "Rick Sanchez",
    status: String = "Alive",
    species: String = "Human",
    type: String = "",
    gender: String = "Male",
    created: String = "2017-11-04T18:48:46.250Z"
) -> String {
    """
    {
        "id": \(id),
        "name": "\(name)",
        "status": "\(status)",
        "species": "\(species)",
        "type": "\(type)",
        "gender": "\(gender)",
        "origin": {"name": "Earth", "url": "https://example.com"},
        "location": {"name": "Earth", "url": "https://example.com"},
        "image": "https://example.com/image.jpeg",
        "episode": ["https://example.com/episode/1"],
        "url": "https://rickandmortyapi.com/api/character/\(id)",
        "created": "\(created)"
    }
    """
}
