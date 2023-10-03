//
//  XModel.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation

// MARK: - XConstant: route

extension XConstant {
    public static let route: String = "XRAY_ROUTE_DATA"
}

// MARK: - XModel

public struct XModel: Codable, Equatable {
    public var domainStrategy: DomainStrategy = .asIs
    public var domainMatcher: DomainMatcher = .hybrid
    public var rules: [Rule] = []
    public var balancers: [Balancer] = []
}

// MARK: - Static properties

extension XModel {
    public static let `default` = XModel()
    public static var current: XModel {
        do {
            guard let data = UserDefaults.shared.data(forKey: XConstant.route) else {
                return .default
            }
            return try JSONDecoder().decode(XModel.self, from: data)
        } catch {
            return .default
        }
    }
}

// MARK: - Submodels

extension XModel {
    // MARK: - DomainStrategy

    public enum DomainStrategy: String, Identifiable, CaseIterable, Codable {
        public var id: Self { self }
        case asIs = "AsIs"
        case ipIfNonMatch = "IPIfNonMatch"
        case ipOnDemand = "IPOnDemand"
    }

    // MARK: - DomainMatcher

    public enum DomainMatcher: String, Identifiable, CaseIterable, Codable {
        public var id: Self { self }
        case hybrid
        case linear
    }

    // MARK: - Outbound

    public enum Outbound: String, Identifiable, CaseIterable, Codable {
        public var id: Self { self }
        case direct
        case proxy
        case block
    }

    // MARK: - Rule

    public struct Rule: Codable, Equatable, Identifiable {
        public var id: UUID { self.__id__ }

        public var domainMatcher: DomainMatcher = .hybrid
        public var type: String = "field"
        public var domain: [String]?
        public var ip: [String]?
        public var port: String?
        public var sourcePort: String?
        public var network: String?
        public var source: [String]?
        public var user: [String]?
        public var inboundTag: [String]?
        public var `protocol`: [String]?
        public var attrs: String?
        public var outboundTag: Outbound = .direct
        public var balancerTag: String?

        public var __id__: UUID = UUID()
        public var __name__: String = ""
        public var __enabled__: Bool = false

        public var __defaultName__: String {
            "Rule_\(self.__id__.uuidString)"
        }
    }

    // MARK: -  Balancer

    public struct Balancer: Codable, Equatable {
        var tag: String
        var selector: [String] = []
    }
}
