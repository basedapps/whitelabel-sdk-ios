//
//  Array+Ext.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 26.09.2023.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
