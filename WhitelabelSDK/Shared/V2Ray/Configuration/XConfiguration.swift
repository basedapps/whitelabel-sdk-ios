//
//  XConfiguration.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 11.05.2023.
//

import Foundation

// MARK: - XConfiguration

public struct XConfiguration: Identifiable {
    public static let currentStoreKey = "XRAY_CURRENT"
    public let id: String

    init(fileName: String) throws {
        if #available(iOS 16.0, *) {
            let folderURL = XConstant.configDirectory.appending(
                component: fileName,
                directoryHint: .isDirectory
            )
            guard FileManager.default.fileExists(atPath: folderURL.path(percentEncoded: false)) else {
                throw NSError.newError("Config file does not exist")
            }
        } else {
            let folderURL = XConstant.configDirectory.appendingPathComponent(fileName, isDirectory: true)
            guard FileManager.default.fileExists(atPath: folderURL.path) else {
                throw NSError.newError("Config file does not exist")
            }
        }
        self.id = fileName
    }
}

// MARK: - XConfigurationModel

public struct XConfigurationModel: Codable {
    public var vmess: VMess

    public var network: XNetwork
    public var tcp: StreamSettings.TCP = .init()
    public var kcp: StreamSettings.KCP = .init()
    public var ws: StreamSettings.WS = .init()
    public var http: StreamSettings.HTTP = .init()
    public var quic: StreamSettings.QUIC = .init()
    public var grpc: StreamSettings.GRPC = .init()

    public var security: XSecurity = .none
    public var tls: StreamSettings.TLS? = nil
    public var reality: StreamSettings.Reality? = nil
}
