//
//  DataRequest.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 24.07.2023.
//

import Foundation

struct DataRequest<T: Decodable>: Decodable {
    let data: T
}
