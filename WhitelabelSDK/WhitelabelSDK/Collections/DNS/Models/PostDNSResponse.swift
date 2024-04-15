//
//  PostDNSResponse.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 06.10.2022.
//

import Foundation

struct GetServersResponse: Codable {
    let servers: [DNSServerType]
}
