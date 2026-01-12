//
//  Presentable.swift
//  Rick and Morty Characters
//
//  Created by Wallace Souza Silva
//

import Foundation

protocol Presentable {
    var presentationValue: String { get }
}

extension Presentable where Self: RawRepresentable, RawValue == String {
    var presentationValue: String {
        rawValue.capitalized
    }
}
