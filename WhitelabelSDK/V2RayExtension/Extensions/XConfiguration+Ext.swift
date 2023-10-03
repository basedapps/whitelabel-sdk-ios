//
//  XConfiguration+Ext.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 12.05.2023.
//

import Foundation

extension XConfiguration {
    func loadData(inboundPort: Int) throws -> Data {
        let file: URL
        if #available(iOS 16.0, *) {
            file = XConstant.configDirectory.appending(component: "\(self.id)/config.json")
        } else {
            file = XConstant.configDirectory.appendingPathComponent("\(self.id)/config.json")
        }
        let data = try Data(contentsOf: file)
        let model = try JSONDecoder().decode(XConfigurationModel.self, from: data)
        return try model.buildConfigurationData(inboundPort: inboundPort)
    }
}
