//
//  WalletAddressModel.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 20.10.2023.
//

import Vapor

struct WalletAddressModel: Content {
    let address: String
}

struct KeywordsResponse: Content {
    let keywords: [String]
}
