//
//  ProxyRouteCollection.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 10.10.2023.
//

import Vapor

final class ProxyRouteCollection { }

extension ProxyRouteCollection: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let proxyGroup = routes.grouped("proxy")
        
        routes.get("**", use: proxyRequest)
        routes.post("**", use: proxyRequest)
        routes.put("**", use: proxyRequest)
        routes.delete("**", use: proxyRequest)
    }
}

extension ProxyRouteCollection {
   private func proxyRequest(_ req: Request) async throws -> ClientResponse {
        try req.validate()
        
        guard let path = req.url.path.split(separator: "/").dropFirst(2).joined(separator: "/").removingPercentEncoding else {
            throw Abort(.badRequest, reason: "Invalid path")
        }
        
        let url = ApplicationConfiguration.shared.backendURLString
        guard let host = ApplicationConfiguration.shared.backendURL.host() else {
            throw Abort(.badRequest, reason: "Invalid host in env")
        }
        var headers = req.headers
        headers.replaceOrAdd(name: "Host", value: host)
        
        let response =  try await req.client.send(req.method, headers: headers, to: "\(url)/\(path)") { clientReq in
            clientReq.body = req.body.data
            clientReq.url.query = req.url.query
        }
        
        return response
    }
}
