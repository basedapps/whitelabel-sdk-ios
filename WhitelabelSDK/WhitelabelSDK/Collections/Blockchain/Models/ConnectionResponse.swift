//
//  ConnectionResponse.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 19.12.2023.
//

import Foundation

struct ConnectionResponse: Codable {
    let key: String
    let signature: String
}

enum NodeProtocol: String {
    case v2ray = "V2RAY"
    case wireguard = "WIREGUARD"
}
