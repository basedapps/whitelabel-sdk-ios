//
//  ServerProtocol.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 10.10.2023.
//

import Foundation

// MARK: - ServerProtocol

enum ServerProtocol: String {
    case all = ""
    case v2ray = "V2RAY"
    case wireguard = "WIREGUARD"
}

// MARK: - Codable, CaseIterable

extension ServerProtocol: Codable, CaseIterable { }
