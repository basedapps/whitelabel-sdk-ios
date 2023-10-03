//
//  XModel+Ext.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 12.05.2023.
//

import Foundation

extension XModel {
    mutating func build() throws -> Any {
        self.rules = self.rules.filter(\.__enabled__)
        return try JSONSerialization.jsonObject(with: try JSONEncoder().encode(self))
    }
}
