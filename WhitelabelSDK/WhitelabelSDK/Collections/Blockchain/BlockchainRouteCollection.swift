//
//  BlockchainRouteCollection.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 19.10.2023.
//

import Vapor
import SentinelWallet

// MARK: - Constants

private struct Constants {
    let path: PathComponent = "blockchain"
    
    let defaultLimit: UInt64 = 10
    let defaultOffset: UInt64 = 0
}
private let constants = Constants()

// MARK: - DNSRouteCollection

struct BlockchainRouteCollection{
    private let nodesProvider: AsyncNodesProviderType
    
    init(nodesProvider: AsyncNodesProviderType = AsyncNodesProvider()) {
        self.nodesProvider = nodesProvider
    }
}

// MARK: - RouteCollection

extension BlockchainRouteCollection: RouteCollection  {
    func boot(routes: RoutesBuilder) throws {
        routes.get(constants.path, "nodes", use: getAvailableNodes)
        routes.get(constants.path, "plans", use: getAvailablePlans)
        routes.get(constants.path, "plans", ":id", "nodes", use: getAvailableNodesForPlan)
    }
}

// MARK: - Requests

private extension BlockchainRouteCollection {
    func getAvailableNodes(_ req: Request) async throws -> [String] {
        try req.validate()
        let limit = req.query[UInt64.self, at: PaginationKeys.limit.rawValue] ?? constants.defaultLimit
        let offset = req.query[UInt64.self, at: PaginationKeys.offset.rawValue] ?? constants.defaultOffset
        return try await nodesProvider.getActiveNodes(limit: limit, offset: offset)
    }   
    
    func getAvailablePlans(_ req: Request) async throws -> [String] {
        try req.validate()
        let limit = req.query[UInt64.self, at: PaginationKeys.limit.rawValue] ?? constants.defaultLimit
        let offset = req.query[UInt64.self, at: PaginationKeys.offset.rawValue] ?? constants.defaultOffset
        return try await nodesProvider.getPlans(limit: limit, offset: offset)
    }
    
    func getAvailableNodesForPlan(_ req: Request) async throws -> [String] {
        try req.validate()
        let limit = req.query[UInt64.self, at: PaginationKeys.limit.rawValue] ?? constants.defaultLimit
        let offset = req.query[UInt64.self, at: PaginationKeys.offset.rawValue] ?? constants.defaultOffset
        guard let id = req.parameters.get("id", as: UInt64.self) else { throw Abort(.badRequest) }
        return try await nodesProvider.getActiveNodes(for: id, limit: limit, offset: offset)
    }
}
