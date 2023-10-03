//
//  StreamSettings.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobevaon 13.07.2023.
//

import Foundation

// MARK: - StreamSettings

public struct StreamSettings: Codable {
    // MARK: - TLS

    public struct TLS: Codable {
        public var serverName: String = ""
        public var allowInsecure: Bool = false
        public var alpn: [ALPN] = ALPN.allCases
        public var fingerprint: Fingerprint = .chrome
    }

    // MARK: - Reality

    public struct Reality: Codable {
        public var show: Bool = false
        public var fingerprint: Fingerprint = .chrome
        public var serverName: String = ""
        public var publicKey: String = ""
        public var shortId: String = ""
        public var spiderX: String = ""
    }

    // MARK: - TCP

    public struct TCP: Codable {
        public struct Header: Codable {
            public var type: XHeaderType = .none
        }
        public var header = Header()
    }

    // MARK: - KCP

    public struct KCP: Codable {
        public struct Header: Codable {
            public var type: XHeaderType = .none
        }
        public var mtu: Int = 1350
        public var tti: Int = 20
        public var uplinkCapacity: Int = 5
        public var downlinkCapacity: Int = 20
        public var congestion: Bool = false
        public var readBufferSize: Int = 1
        public var writeBufferSize: Int = 1
        public var header = Header()
        public var seed: String = ""
    }

    // MARK: - WS

    public struct WS: Codable {
        public var path: String = "/"
        public var headers: [String: String] = [:]
    }

    // MARK: - HTTP

    public struct HTTP: Codable {
        public var host: [String] = []
        public var path: String = "/"
    }

    // MARK: - QUIC

    public struct QUIC: Codable {
        public struct Header: Codable {
            public var type: XHeaderType = .none
        }
        public var XSecurity = XEncryption.none
        public var key: String = ""
        public var header = Header()
    }

    // MARK: - GRPC

    public struct GRPC: Codable {
        public var serviceName: String = ""
        public var multiMode: Bool = false
    }
}
