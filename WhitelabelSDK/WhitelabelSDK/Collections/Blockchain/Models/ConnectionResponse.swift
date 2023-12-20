//
//  ConnectionResponse.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 19.12.2023.
//

import Foundation

struct CredentialsRequest: Decodable {
    let url: String
    let nodeProtocol: String
    let address: String
    let session: UInt64
}

struct StartSessionRequest: Codable {
    let key: String
    let signature: String
    
    init(key: String, signature: String) {
        self.key = key
        self.signature = signature
    }
}

enum NodeProtocol: String {
    case v2ray = "V2RAY"
    case wireguard = "WIREGUARD"
}
