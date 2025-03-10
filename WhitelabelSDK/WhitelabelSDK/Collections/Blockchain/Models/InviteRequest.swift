//
//  InviteRequest.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 10.03.2025.
//

import Vapor

struct InviteRequest: Content {
    let title: String?
    let canonicalIdentifier: String
    let customMetadata: [String: String]
}
