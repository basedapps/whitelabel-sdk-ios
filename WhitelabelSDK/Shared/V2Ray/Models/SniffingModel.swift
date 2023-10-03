//
//  SniffingModel.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation

// MARK: - XConstant: sniffing

extension XConstant {
    public static let sniffing: String = "XRAY_SNIFFIN_DATA"
}

// MARK: - SniffingModel

public struct SniffingModel: Codable, Equatable {
    public let enabled: Bool
    public let destOverride: [String]
    public let metadataOnly: Bool
    public let routeOnly: Bool
    public let excludedDomains: [String]
}

// MARK: - Static properties

extension SniffingModel {
    public static let `default` = SniffingModel(
        enabled: true,
        destOverride: ["http", "tls"],
        metadataOnly: false,
        routeOnly: false,
        excludedDomains: []
    )
    
    public static var current: SniffingModel {
        do {
            guard let data = UserDefaults.shared.data(forKey: XConstant.sniffing) else {
                return .default
            }
            return try JSONDecoder().decode(SniffingModel.self, from: data)
        } catch {
            return .default
        }
    }
}
