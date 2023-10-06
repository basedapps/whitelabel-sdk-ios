//
//  Data+Ext.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 25.07.2023.
//

import Foundation

extension Data {
    var bytes: Array<UInt8> {
        Array(self)
    }
}
