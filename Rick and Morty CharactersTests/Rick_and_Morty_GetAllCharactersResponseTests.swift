//
//  Rick_and_Morty_GetAllCharactersResponseTests.swift
//  Rick and Morty CharactersTests
//
//  Created by Copilot
//

import XCTest
@testable import Rick_and_Morty_Characters

final class Rick_and_Morty_GetAllCharactersResponseTests: XCTestCase {

    func testDecodeFullResponse() throws {
        let data = Data(listResponseJson.utf8)
        let response = try JSONDecoder().decode(GetAllCharactersResponse.self, from: data)

        XCTAssertEqual(response.results.count, 3)
        XCTAssertNotNil(response.info.next)
        XCTAssertEqual(response.info.next, "https://rickandmortyapi.com/api/character?page=2")
    }

    func testDecodeResponseWithNoNextPage() throws {
        let data = Data(listResponseWithNoNextPageJson.utf8)
        let response = try JSONDecoder().decode(GetAllCharactersResponse.self, from: data)

        XCTAssertEqual(response.results.count, 1)
        XCTAssertNil(response.info.next)
    }

    func testDecodeResponseCharacterDetails() throws {
        let data = Data(listResponseJson.utf8)
        let response = try JSONDecoder().decode(GetAllCharactersResponse.self, from: data)

        let rick = response.results[0]
        XCTAssertEqual(rick.id, 1)
        XCTAssertEqual(rick.name, "Rick Sanchez")
        XCTAssertEqual(rick.status, .alive)

        let morty = response.results[1]
        XCTAssertEqual(morty.id, 2)
        XCTAssertEqual(morty.name, "Morty Smith")

        let summer = response.results[2]
        XCTAssertEqual(summer.id, 3)
        XCTAssertEqual(summer.name, "Summer Smith")
        XCTAssertEqual(summer.gender, .female)
    }

    func testDecodeInvalidResponseThrows() {
        let invalidJson = """
        {"invalid": true}
        """
        let data = Data(invalidJson.utf8)

        XCTAssertThrowsError(try JSONDecoder().decode(GetAllCharactersResponse.self, from: data))
    }
}
