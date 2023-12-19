//
//  PostSessionRequest.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 19.12.2023.
//

import Foundation

struct PostSessionRequest: Codable {
    let activeSession: UInt64?
    let subscriptionID: UInt64
    let node: String
}
