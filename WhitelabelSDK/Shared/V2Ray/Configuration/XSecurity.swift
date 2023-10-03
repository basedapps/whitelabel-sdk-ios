//
//  XSecurity.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation

// MARK: - XSecurity

public enum XSecurity: String, Identifiable, CaseIterable, Codable {
    public var id: Self { self }

    case none
    case tls
    case reality
}
