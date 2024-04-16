//
//  PostDNSResponse.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 06.10.2022.
//

import Foundation
import Vapor

struct GetServersResponse: Codable, Content {
    let servers: [DNSServerType]
}
