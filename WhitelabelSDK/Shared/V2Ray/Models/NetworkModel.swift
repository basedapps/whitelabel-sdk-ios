//
//  NetworkModel.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation

// MARK: - XConstant: network

extension XConstant {
    public static let network: String = "NETWORK_DATA"
}

// MARK: - NetworkModel

public struct NetworkModel: Codable, Equatable {
    public let hideVPNIcon: Bool
    public let ipv6Enabled: Bool
    public let inboundPort: Int
}

// MARK: - Static properties

extension NetworkModel {
    public static let `default` = NetworkModel(
        hideVPNIcon: false,
        ipv6Enabled: false,
        inboundPort: 8080
    )
    
    public static var current: NetworkModel {
        do {
            guard let data = UserDefaults.shared.data(forKey: XConstant.network) else {
                return .default
            }
            return try JSONDecoder().decode(NetworkModel.self, from: data)
        } catch {
            return .default
        }
    }
}
