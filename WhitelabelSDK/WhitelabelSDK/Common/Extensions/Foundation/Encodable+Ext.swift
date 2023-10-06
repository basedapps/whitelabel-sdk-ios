//
//  Encodable+Ext.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 21.07.2023.
//

import Foundation

extension Encodable {
    func toData() -> Data? {
        Serializer.toData(from: self)
    }
}

extension Encodable {
    func asJSONString() throws -> String {
        let data = try JSONEncoder().encode(self)
        guard let string = String(data: data, encoding: String.Encoding.utf8) else {
            throw NSError()
        }
        return string
    }

    var JSONString: String? {
        try? asJSONString()
    }
}
