//
//  IPResponse.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 25.03.2024.
//

import Foundation

struct IPResponse: Decodable, Equatable {
    let ip: String
    
    let latitude: Float64?
    let longitude: Float64?
}
