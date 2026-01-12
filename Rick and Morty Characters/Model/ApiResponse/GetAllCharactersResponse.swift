//
//  GetAllCharactersResponse.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation

struct GetAllCharactersResponse: Codable {
    
    struct Info: Codable {
        let next: String?
    }
    
    let info: Info
    let results: [Character]
}
