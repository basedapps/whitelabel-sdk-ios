//
//  WalletAddressResponse.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 20.10.2023.
//

import Foundation

struct WalletAddressResponse: Codable {
    let address: String
}

struct WalletBalanceResponse: Codable {
    let balance: Int
    let currency: String
}
