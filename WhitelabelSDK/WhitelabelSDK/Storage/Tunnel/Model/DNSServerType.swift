//
//  DNSServerType.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 29.11.2021.
//

import SwiftUI

// MARK: - DNSServerType

enum DNSServerType: String, CaseIterable {
    case handshake
    case google
    case cloudflare

    var address: String {
        switch self {
        case .cloudflare:
            return "1.1.1.1, 1.0.0.1"
        case .google:
            return "8.8.8.8, 8.8.4.4"
        case .handshake:
            return "103.196.38.38, 103.196.38.39"
        }
    }

    var addresses: [String] {
        address.splitToArray(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    static var `default`: DNSServerType {
        return .handshake
    }
}

// MARK: - Codable

extension DNSServerType: Codable {}
