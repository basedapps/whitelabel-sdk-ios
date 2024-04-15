//
//  DNSServerType.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 29.11.2021.
//

// MARK: - DNSServerType

struct DNSServerType {
    let name: String
    let addresses: String
}

extension DNSServerType {
    static var handshake: DNSServerType = .init(name: "handshake", addresses: "103.196.38.38, 103.196.38.39")
    static var google: DNSServerType = .init(name: "google", addresses: "8.8.8.8, 8.8.4.4")
    static var cloudflare: DNSServerType = .init(name: "cloudflare", addresses: "1.1.1.1, 1.0.0.1")
}
 
extension DNSServerType {
    var rawAddresses: [String] {
        addresses.splitToArray(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    static var allCases: [DNSServerType] = [.cloudflare, .google, .handshake]
    
    static var `default`: DNSServerType {
        .cloudflare
    }
}

// MARK: - Codable

extension DNSServerType: Codable {}
