//
//  Route.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation

// MARK: - RouteDomainStrategy

public enum RouteDomainStrategy: String, Identifiable, CaseIterable, Codable {
    public var id: Self { self }

    case asIs
    case ipIfNonMatch
    case ipOnDemand
}

// MARK: - RoutePredefinedRule

public enum RoutePredefinedRule: String, Identifiable, CaseIterable, Codable {
    public var id: Self { self }

    case global
    case rule
    case direct
}
