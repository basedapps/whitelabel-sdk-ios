//
//  SniffingModel+Ext.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 12.05.2023.
//

import Foundation

extension SniffingModel {
    func build() throws -> Any {
        var sniffing: [String: Any] = [:]
        sniffing["enabled"] = self.enabled
        sniffing["metadataOnly"] = self.metadataOnly
        sniffing["domainsExcluded"] = self.excludedDomains
        sniffing["routeOnly"] = self.routeOnly
        return sniffing
    }
}
