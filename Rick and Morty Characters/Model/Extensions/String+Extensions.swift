//
//  String+Extensions.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation

extension String {
    /// Returns the last slash-delimited component of the string,
    /// matching the URL path behaviour of `URL.lastPathComponent`.
    var lastPathComponent: String {
        components(separatedBy: "/").last ?? self
    }
}
