//
//  Rick_and_Morty_CharacterEnumsTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Copilot
//

import XCTest
@testable import Rick_and_Morty_Characters

final class Rick_and_Morty_CharacterEnumsTests: XCTestCase {

    // MARK: - CharacterStatus

    func testCharacterStatusRawValues() {
        XCTAssertEqual(CharacterStatus.alive.rawValue, "alive")
        XCTAssertEqual(CharacterStatus.dead.rawValue, "dead")
        XCTAssertEqual(CharacterStatus.unknown.rawValue, "unknown")
        XCTAssertEqual(CharacterStatus.undefined.rawValue, "undefined")
    }

    func testCharacterStatusCaseIterable() {
        let allCases = CharacterStatus.allCases
        XCTAssertTrue(allCases.contains(.alive))
        XCTAssertTrue(allCases.contains(.dead))
        XCTAssertTrue(allCases.contains(.unknown))
        XCTAssertTrue(allCases.contains(.undefined))
        XCTAssertEqual(allCases.count, 4)
    }

    func testCharacterStatusPresentationValue() {
        XCTAssertEqual(CharacterStatus.alive.presentationValue, "Alive")
        XCTAssertEqual(CharacterStatus.dead.presentationValue, "Dead")
        XCTAssertEqual(CharacterStatus.unknown.presentationValue, "Unknown")
        XCTAssertEqual(CharacterStatus.undefined.presentationValue, "Undefined")
    }

    func testCharacterStatusInitFromRawValue() {
        XCTAssertEqual(CharacterStatus(rawValue: "alive"), .alive)
        XCTAssertEqual(CharacterStatus(rawValue: "dead"), .dead)
        XCTAssertEqual(CharacterStatus(rawValue: "unknown"), .unknown)
        XCTAssertEqual(CharacterStatus(rawValue: "undefined"), .undefined)
        XCTAssertNil(CharacterStatus(rawValue: "invalid"))
    }

    // MARK: - CharacterGender

    func testCharacterGenderRawValues() {
        XCTAssertEqual(CharacterGender.male.rawValue, "male")
        XCTAssertEqual(CharacterGender.female.rawValue, "female")
        XCTAssertEqual(CharacterGender.genderless.rawValue, "genderless")
        XCTAssertEqual(CharacterGender.unknown.rawValue, "unknown")
        XCTAssertEqual(CharacterGender.undefined.rawValue, "undefined")
    }

    func testCharacterGenderPresentationValue() {
        XCTAssertEqual(CharacterGender.male.presentationValue, "Male")
        XCTAssertEqual(CharacterGender.female.presentationValue, "Female")
        XCTAssertEqual(CharacterGender.genderless.presentationValue, "Genderless")
        XCTAssertEqual(CharacterGender.unknown.presentationValue, "Unknown")
        XCTAssertEqual(CharacterGender.undefined.presentationValue, "Undefined")
    }

    func testCharacterGenderInitFromRawValue() {
        XCTAssertEqual(CharacterGender(rawValue: "male"), .male)
        XCTAssertEqual(CharacterGender(rawValue: "female"), .female)
        XCTAssertEqual(CharacterGender(rawValue: "genderless"), .genderless)
        XCTAssertEqual(CharacterGender(rawValue: "unknown"), .unknown)
        XCTAssertEqual(CharacterGender(rawValue: "undefined"), .undefined)
        XCTAssertNil(CharacterGender(rawValue: "invalid"))
    }

    // MARK: - NetworkingError

    func testNetworkingErrorCases() {
        let badUrl = NetworkingError.badUrl
        let badComponents = NetworkingError.badUrlComponents
        let request = NetworkingError.request(500)

        // Verify they are Error types
        XCTAssertNotNil(badUrl as Error)
        XCTAssertNotNil(badComponents as Error)
        XCTAssertNotNil(request as Error)

        // Verify request carries status code
        if case .request(let code) = request {
            XCTAssertEqual(code, 500)
        } else {
            XCTFail("Expected .request case")
        }
    }
}
