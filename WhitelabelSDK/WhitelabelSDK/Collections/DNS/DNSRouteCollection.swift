//
//  DNSRouteCollection.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 06.10.2022.
//

import Foundation
import Vapor

// MARK: - Constants

private struct Constants {
    let path: PathComponent = "dns"
}
private let constants = Constants()

// MARK: - DNSRouteCollection

struct DNSRouteCollection{
    private let storage: StoresTunnelsInfo
    
    init(storage: StoresTunnelsInfo = GeneralSettingsStorage()) {
        self.storage = storage
    }
}

// MARK: - RouteCollection

extension DNSRouteCollection: RouteCollection  {
    func boot(routes: RoutesBuilder) throws {
        routes.get(constants.path, "list", use: getAvailableDNS)
        routes.get(constants.path, "current", use: getSelectedDNS)
        routes.put(constants.path, use: putDNS)
    }
}

// MARK: - Requests

extension DNSRouteCollection {
    private func getAvailableDNS(_ req: Request) async throws -> GetServersResponse {
        try req.validate()
        let servers = DNSServerType.allCases
        return GetServersResponse(servers: servers)
    }
    
    private func getSelectedDNS(_ req: Request) async throws -> DNSServerType {
        try req.validate()
        return storage.selectedDNS
    }
    
    private func putDNS(_ req: Request) throws -> Response {
        try req.validate()
        let body = try req.content.decode(DNSServerType.self)
        storage.selectedDNS = body
        return Response(status: .ok)
    }
}
