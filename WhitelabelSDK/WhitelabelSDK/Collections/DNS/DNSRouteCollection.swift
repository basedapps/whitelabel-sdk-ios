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
    private func getAvailableDNS(_ req: Request) async throws -> String {
        try req.validate()
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            let servers = DNSServerType.allCases.map(AvailableDNSServer.init(from:))
            let body = PostDNSResponse(servers: servers)
            
            DefaultEncoder.encode(model: body, continuation: continuation)
        })
    }
    
    private func getSelectedDNS(_ req: Request) async throws -> String {
        try req.validate()
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            let dnsServer = storage.selectedDNS
            let body = AvailableDNSServer(from: dnsServer)
            
            DefaultEncoder.encode(model: body, continuation: continuation)
        })
    }
    
    private func putDNS(_ req: Request) throws -> Response {
        try req.validate()
        
        do {
            let body = try req.content.decode(PostDNSRequest.self)
            let server = body.server
            
            guard let type = DNSServerType(rawValue: server) else {
                return Response(status: .badRequest)
            }
            
            storage.selectedDNS = type
            return Response(status: .ok)
        } catch {
            return Response(status: .badRequest)
        }
    }
}
