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

struct StartSessionResponse: Decodable {
    let success: Bool
    let result: String?
    let error: StartSessionError?
}

struct StartSessionError: Decodable {
    let message: String?
}
