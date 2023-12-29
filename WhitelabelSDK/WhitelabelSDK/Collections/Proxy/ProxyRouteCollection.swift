//
//  ProxyRouteCollection.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 10.10.2023.
//

import Vapor

struct IPResponse: Decodable, Equatable {
    let ip: String
    
    let latitude: Float64?
    let longitude: Float64?
}

final class ProxyRouteCollection { }

extension ProxyRouteCollection: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let proxyGroup = routes.grouped("proxy")
        
        proxyGroup.get("**", use: proxyRequest)
        proxyGroup.get("ip", use: getIP)
        proxyGroup.post("**", use: proxyRequest)
        proxyGroup.put("**", use: proxyRequest)
        proxyGroup.delete("**", use: proxyRequest)
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
    
    private func getIP(_ req: Request) async throws -> String {
        try req.validate()
        let url = ApplicationConfiguration.shared.backendURLString + "/ip"
        let urlString = "https://vpn-api.basedapps.co.uk/ip"
        guard let url = URL(string: urlString) else { throw Abort(.badRequest) }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = req.headers.first(name: "x-device-token") else { throw Abort(.unauthorized) }
        request.addValue(token, forHTTPHeaderField: "x-device-token")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return String(decoding: data, as: UTF8.self)
    }
}
