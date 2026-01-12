//
//  CharacterStatus.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation

enum CharacterStatus: String, Codable, CaseIterable, Presentable {
    case undefined
    case alive, dead, unknown    
}
