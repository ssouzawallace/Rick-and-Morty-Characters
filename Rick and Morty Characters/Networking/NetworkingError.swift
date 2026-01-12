//
//  NetworkingError.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation

enum NetworkingError: Error {
    case badUrl, badUrlComponents, request(Int)
}
