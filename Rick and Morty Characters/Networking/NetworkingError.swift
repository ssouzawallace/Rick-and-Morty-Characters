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

// MARK: - Readable messages

/// Without this the error alerts read "The operation couldn't be completed.
/// (Rick_and_Morty_Characters.NetworkingError error 0.)", which tells the reader
/// nothing — and is actively misleading, since Swift bridges a case with an
/// associated value to code 0 regardless of the status code it carries.
extension NetworkingError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .badUrl, .badUrlComponents:
            return "Could not build a valid request for the Rick and Morty API."

        case .request(let statusCode):
            switch statusCode {
            case 404:
                return "The Rick and Morty API has nothing at that address (404)."
            case 429:
                return "The Rick and Morty API is rate limiting requests (429). Wait a moment and try again."
            case 500 ..< 600:
                return "The Rick and Morty API is having trouble (\(statusCode)). Try again shortly."
            default:
                return "The request to the Rick and Morty API failed (\(statusCode))."
            }
        }
    }
}
