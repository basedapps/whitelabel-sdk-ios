//
//  PurchasesRouteCollection.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 06.08.2024.
//

import Foundation
import Vapor
import RevenueCat

// MARK: - PurchasesRouteCollection

final class PurchasesRouteCollection { }

// MARK: - RouteCollection

extension PurchasesRouteCollection: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("purchases")
        group.post("setup", use: setup)
        group.post("login", use: login)
        group.post("buy", use: buy)
        group.get("products", use: getProducts)
    }
}

// MARK: - Requests

extension PurchasesRouteCollection {
    private func setup(_ req: Request) throws -> Response {
        try req.validate()
        let body = try req.content.decode(APIKeyModel.self)
        Purchases.configure(withAPIKey: body.key)
        return Response(status: .ok)
    }    
    
    private func login(_ req: Request) async throws -> Response {
        try req.validate()
        let body = try req.content.decode(WalletAddressModel.self)
        let _ = try await Purchases.shared.logIn(body.address)
        
        return Response(status: .ok)
    } 
    
    private func getProducts(_ req: Request) async throws -> CurrentOffering {
        try req.validate()
        guard let offering = try await Purchases.shared.offerings().current else {
            throw Abort(.notFound)
        }
        
        return CurrentOffering(offering: offering)
    }
    
    private func buy(_ req: Request) async throws -> StoreTransactionResultModel {
        try req.validate()
        let body = try req.content.decode(PackageModel.self)
        guard let package = Purchases.shared.cachedOfferings?.current?.availablePackages
            .first(where: { $0.identifier == body.identifier }) else {
            throw Abort(.notFound)
        }
        let result = try await Purchases.shared.purchase(package: package)
        
        return StoreTransactionResultModel(result: result)
    }
}
