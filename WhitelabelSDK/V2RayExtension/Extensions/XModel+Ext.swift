//
//  XModel+Ext.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 12.05.2023.
//

import Foundation

// MARK: - Public methods

extension XConfigurationModel {
    func buildConfigurationData(inboundPort: Int) throws -> Data {
        var configuration: [String: Any] = [:]
        configuration["inbounds"] = [try self.buildInbound(inboundPort: inboundPort)]
        var route = XModel.current
        configuration["routing"] = try route.build()
        configuration["outbounds"] = [
            try self.buildProxyOutbound(),
            try self.buildDirectOutbound(),
            try self.buildBlockOutbound()
        ]
        NSLog(String(data: try JSONSerialization.data(withJSONObject: try route.build(), options: .sortedKeys), encoding: .utf8) ?? "---")
        return try JSONSerialization.data(withJSONObject: configuration, options: .prettyPrinted)
    }
}

// MARK: - Private methods

extension XConfigurationModel {
    private func buildInbound(inboundPort: Int) throws -> Any {
        var inbound: [String: Any] = [:]
        inbound["listen"] = "[::1]"
        inbound["protocol"] = "socks"
        inbound["settings"] = ["udp": true, "auth": "noauth"] as [String : Any]
        inbound["tag"] = "socks-in"
        inbound["port"] = inboundPort
        inbound["sniffing"] = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(SniffingModel.current))
        return inbound
    }

    private func buildProxyOutbound() throws -> Any {
        var proxy: [String: Any] = [:]
        proxy["tag"] = "proxy"
        proxy["protocol"] = "vmess"
        proxy["settings"] = ["vnext": [try JSONSerialization.jsonObject(with: try JSONEncoder().encode(vmess))]]
        var streamSettings: [String: Any] = [:]
        streamSettings["network"] = self.network.rawValue
        switch self.network {
        case .tcp:
            streamSettings["tcpSettings"] = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(tcp))
        case .kcp:
            streamSettings["kcpSettings"] = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(kcp))
        case .ws:
            streamSettings["wsSettings"] = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(ws))
        case .http:
            streamSettings["httpSettings"] = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(http))
        case .quic:
            streamSettings["quicSettings"] = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(quic))
        case .grpc:
            streamSettings["grpcSettings"] = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(grpc))
        }
        streamSettings["security"] = self.security.rawValue
        switch self.security {
        case .none:
            break
        case .tls:
            guard let tls = self.tls else {
                throw NSError.newError("\(self.security.rawValue) build failed")
            }
            streamSettings["tlsSettings"] = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(tls))
        case .reality:
            guard let reality = self.reality else {
                throw NSError.newError("\(self.security.rawValue) build failed")
            }
            streamSettings["realitySettings"] = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(reality))
        }
        proxy["streamSettings"] = streamSettings
        return proxy
    }

    private func buildDirectOutbound() throws -> Any {
        [
            "tag": "direct",
            "protocol": "freedom"
        ]
    }

    private func buildBlockOutbound() throws -> Any {
        [
            "tag": "block",
            "protocol": "blackhole"
        ]
    }
}
