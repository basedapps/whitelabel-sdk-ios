//
//  LocalValue.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 06.10.2023.
//

import Foundation

struct LocalValue: Codable {
    let key: String
    let value: String
    let isSecure: Bool
}

// MARK: - Codable implementation

extension LocalValue {
    enum CodingKeys: String, CodingKey {
        case key
        case value
        case isSecure = "is_secure"
    }
}
