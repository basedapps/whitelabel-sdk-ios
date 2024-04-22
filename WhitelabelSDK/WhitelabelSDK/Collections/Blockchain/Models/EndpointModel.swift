//
//  EndpointModel.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 20.10.2023.
//

import Vapor

struct EndpointModel: Content {
    let host: String
    let port: Int
}
