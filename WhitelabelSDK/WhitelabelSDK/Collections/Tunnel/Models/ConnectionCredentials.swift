//
//  ConnectionCredentials.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 10.10.2023.
//

import Foundation

// MARK: - Credentials

struct ConnectionCredentials: Equatable {
     let vpnProtocol: ServerProtocol

     let payload: String
     let privateKey: String?
     let uid: String?

     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let rawType = try container.decode(String.self, forKey: .vpnProtocol)
        vpnProtocol = .init(rawValue: rawType) ?? .wireguard

        payload = try container.decode(String.self, forKey: .payload)
        privateKey = try? container.decode(String.self, forKey: .privateKey)
        uid = try? container.decode(String.self, forKey: .uid)
    }

    init(vpnProtocol: ServerProtocol, payload: String, uid: String? = nil, privateKey: String? = nil) {
        self.vpnProtocol = vpnProtocol
        self.payload = payload
        self.uid = uid
        self.privateKey = privateKey
    }
}

// MARK: - Decodable

extension ConnectionCredentials: Codable {
    enum CodingKeys: String, CodingKey {
        case vpnProtocol = "protocol"
        case payload
        case privateKey = "private_key"
        case uid
    }
}
