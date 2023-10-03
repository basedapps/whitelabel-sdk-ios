//
//  PacketTunnelProvider.swift
//  V2RayExtension
//
//  Created by Lika Vorobeva on 03.10.2023.
//

import NetworkExtension
import XrayKit
import Tun2SocksKit
import os

// MARK: -  PacketTunnelProvider

final class PacketTunnelProvider: NEPacketTunnelProvider {
    private let instance = XrayInstance()
    private let logger = Logger(subsystem: Bundle.providerBundleIdentifier, category: "Core")

    override init() {
        super.init()
        Config.setup()
        XrayRegisterOSLogger(self)
    }

    override func startTunnel(options: [String : NSObject]? = nil) async throws {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "254.1.1.1")
        settings.mtu = 9000
        let network = NetworkModel.current
        settings.ipv4Settings = {
            let settings = NEIPv4Settings(addresses: ["198.18.0.1"], subnetMasks: ["255.255.0.0"])
            settings.includedRoutes = [NEIPv4Route.default()]
            if network.hideVPNIcon {
                settings.excludedRoutes = [NEIPv4Route(destinationAddress: "0.0.0.0", subnetMask: "255.0.0.0")]
            }
            return settings
        }()
        settings.ipv6Settings = {
            guard network.ipv6Enabled else {
                return nil
            }
            let settings = NEIPv6Settings(addresses: ["fd6e:a81b:704f:1211::1"], networkPrefixLengths: [64])
            settings.includedRoutes = [NEIPv6Route.default()]
            if network.hideVPNIcon {
                settings.excludedRoutes = [NEIPv6Route(destinationAddress: "::", networkPrefixLength: 128)]
            }
            return settings
        }()
        settings.dnsSettings = NEDNSSettings(servers: XConstant.dns)
        try await setTunnelNetworkSettings(settings)
        do {
            try self.startXray(inboundPort: network.inboundPort)
            try self.startSocks5Tunnel(serverPort: network.inboundPort)
        } catch {
            log.error(error)
            throw error
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason) async {
        let message: String
        switch reason {
        case .none:
            message = "No specific reason."
        case .userInitiated:
            message = "The user stopped the provider."
        case .providerFailed:
            message = "The provider failed."
        case .noNetworkAvailable:
            message = "There is no network connectivity."
        case .unrecoverableNetworkChange:
            message = "The device attached to a new network."
        case .providerDisabled:
            message = "The provider was disabled."
        case .authenticationCanceled:
            message = "The authentication process was cancelled."
        case .configurationFailed:
            message = "The provider could not be configured."
        case .idleTimeout:
            message = "The provider was idle for too long."
        case .configurationDisabled:
            message = "The associated configuration was disabled."
        case .configurationRemoved:
            message = "The associated configuration was deleted."
        case .superceded:
            message = "A high-priority configuration was started."
        case .userLogout:
            message = "The user logged out."
        case .userSwitch:
            message = "The active user changed."
        case .connectionFailed:
            message = "Failed to establish connection."
        case .sleep:
            message = "The device went to sleep and disconnectOnSleep is enabled in the configuration."
        case .appUpdate:
            message = "The NEProvider is being updated."
        @unknown default:
            return
        }
        log.error(message)
    }
}

// MARK: - Private

extension PacketTunnelProvider {
    private func startXray(inboundPort: Int) throws {
        let configuration = try XConfiguration(fileName: XConfiguration.currentStoreKey)
        let data = try configuration.loadData(inboundPort: inboundPort)
        let configurationFilePath: String
        if #available(iOS 16.0, *) {
            configurationFilePath = XConstant.cachesDirectory
                .appending(component: "config.json")
                .path(percentEncoded: false)
        } else {
            configurationFilePath = XConstant.cachesDirectory
                .appendingPathComponent("config.json", isDirectory: true)
                .path
        }
        guard FileManager.default.createFile(atPath: configurationFilePath, contents: data) else {
            throw NSError.newError("Xray failed to write configuration file")
        }

        try instance.run(self)
    }

    private func startSocks5Tunnel(serverPort port: Int) throws {
        let config = """
        tunnel:
          mtu: 9000
        socks5:
          port: \(port)
          address: ::1
          udp: 'udp'
        misc:
          task-stack-size: 20480
          connect-timeout: 5000
          read-write-timeout: 60000
          log-file: stderr
          log-level: error
          limit-nofile: 65535
        """
        let configurationFilePath: String
        if #available(iOS 16.0, *) {
            configurationFilePath = XConstant.cachesDirectory
                .appending(component: "config.yml")
                .path(percentEncoded: false)
        } else {
            configurationFilePath = XConstant.cachesDirectory
                .appendingPathComponent("config.yml", isDirectory: true)
                .path
        }
        guard FileManager.default.createFile(atPath: configurationFilePath, contents: config.data(using: .utf8)!) else {
            throw NSError.newError("Tunnel failed to write configuration file")
        }
        DispatchQueue.global(qos: .userInitiated).async {
            NSLog("HEV_SOCKS5_TUNNEL_MAIN: \(Socks5Tunnel.run(withConfig: configurationFilePath))")
        }
    }
}

// MARK: - XrayClientProtocol

extension PacketTunnelProvider: XrayClientProtocol {
    func onPrepare(_ env: XrayEnvironmentProtocol?) throws {
        let cachesDirectory: String
        let assetDirectory: String
        if #available(iOS 16.0, *) {
            cachesDirectory = XConstant.cachesDirectory.path(percentEncoded: false)
            assetDirectory = XConstant.assetDirectory.path(percentEncoded: false)
        } else {
            cachesDirectory = XConstant.cachesDirectory.path
            assetDirectory = XConstant.assetDirectory.path
        }
        try env?.set("XRAY_LOCATION_CONFIG", value: cachesDirectory)
        try env?.set("XRAY_LOCATION_ASSET", value: assetDirectory)
    }

    func onServerRunning() {}
    func onTrafficUpdate(_ up: Int64, down: Int64) {}
}

// MARK: - XrayLoggerProtocol

extension PacketTunnelProvider: XrayOSLoggerProtocol {
    func onAccessLog(_ message: String?) {
        guard let message = message else { return }
        logger.log("\(message, privacy: .public)")
        log.debug(message)
    }

    func onDNSLog(_ message: String?) {
        guard let message = message else { return }
        logger.log("\(message, privacy: .public)")
        log.debug(message)
    }

    func onGeneralMessage(_ severity: String?, message: String?) {
        let level = XLogModel.Severity(rawValue: severity ?? "Unknown") ?? .none
        guard let message = message, !message.isEmpty else { return }
        switch level {
        case .debug:
            log.debug(message)
            logger.debug("\(message, privacy: .public)")
        case .info:
            log.info(message)
            logger.info("\(message, privacy: .public)")
        case .warning:
            log.warning(message)
            logger.warning("\(message, privacy: .public)")
        case .error:
            log.error(message)
            logger.error("\(message, privacy: .public)")
        case .unknown:
            break
        case .none:
            break
        }
    }
}
