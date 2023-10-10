//
//  TunnelManager.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 28.09.2021.
//

import Foundation
import WireGuardKit

// MARK: - Constants

private struct Constants {
    let persistentKeepAlive = "25"
    let allowedIPs = "0.0.0.0/0"
    let wireguardTunnelName = "WhitelabelSDK — WireGuard"

    let protocolType = URL(string: "vmess://")!
}
private let constants = Constants()

// MARK: - TunnelManagerDelegate

protocol TunnelManagerDelegate: AnyObject {
    func handleTunnelUpdatingStatus()
    func handleError(_ error: Error)
    func handleTunnelReconnection()
    func handleTunnelServiceCreation()
}

// MARK: - TunnelManager

final class TunnelManager {
    private let storage: StoresTunnelsInfo
    
    private var tunnelModel: TunnelModel
    private var tunnelsService: TunnelsService?
    
    weak var delegate: TunnelManagerTypeDelegate? {
        didSet {
            tunnelsService?.statusDelegate = delegate
        }
    }

    init(
        storage: StoresTunnelsInfo = GeneralSettingsStorage(),
        tunnelModel: TunnelModel = TunnelModel(tunnelConfiguration: nil)
    ) {
        self.storage = storage
        self.tunnelModel = tunnelModel
        
        createTunnelService()
    }
}

// MARK: - TunnelManagerType: Common

extension TunnelManager: TunnelManagerType {
    var lastTunnel: TunnelContainer? {
        tunnelsService?.tunnels.last
    }

    var isTunnelActive: Bool {
        tunnelsService?.tunnels.last?.status == .connected
    }

    @discardableResult
    func startDeactivationOfActiveTunnel() -> Bool {
        tunnelsService?.startDeactivationOfActiveTunnel() ?? false
    }

    func startActivation(of tunnel: TunnelContainer) {
        tunnelsService?.set(onDemandEnabled: true, for: tunnel) { [weak self] _ in
            self?.tunnelsService?.startActivation(of: tunnel)
        }
    }

    func startDeactivation(of tunnel: TunnelContainer) {
        tunnelsService?.set(onDemandEnabled: false, for: tunnel) { [weak self] _ in
            self?.tunnelsService?.startDeactivation(of: tunnel)
        }
    }

    func update(with server: String) {
        guard isTunnelActive, let tunnel = lastTunnel else {
            return
        }

        switch tunnel.type {
        case .v2ray:
            UserDefaults.shared.setValue(storage.selectedDNS.addresses, forKey: XConstant.dnsKey)
        case .wireguard:
            tunnelModel.interfaceModel[.dns] = server
            upsertTunnel(startActivation: false)
        default:
            log.error("Unsupported protocol")
        }
    }

    func resetVPNConfiguration(completion: @escaping (TunnelsServiceError?) -> Void) {
        guard let tunnelsService = tunnelsService else { return }
        tunnelsService.removeMultiple(tunnels: tunnelsService.tunnels, completion: completion)
    }
}

// MARK: - Wireguard

extension TunnelManager {
    func startTest() {
        delegate?.handleTunnelUpdatingStatus()
    }
    
    func startWireguard(from credentials: ConnectionCredentials) -> TunnelsServiceError? {
        delegate?.handleTunnelUpdatingStatus()
        
        guard let rawKey = credentials.privateKey, let privateKey = PrivateKey(base64Key: rawKey) else {
            return .emptyCredentials
        }
        
        guard let data = Data(base64Encoded: credentials.payload), data.bytes.count == 58 else {
            return .emptyCredentials
        }

        tunnelModel.interfaceModel[.privateKey] = privateKey.base64Key
        tunnelModel.interfaceModel[.publicKey] = privateKey.publicKey.base64Key

        tunnelModel.interfaceModel[.dns] = storage.selectedDNS.address

        tunnelModel.interfaceModel[.addresses] = "\(data[0]).\(data[1]).\(data[2]).\(data[3])/32"
        let port = data.bytes[24...25]
            .withUnsafeBytes { $0.load(as: UInt16.self) }
            .bigEndian
            .description

        tunnelModel.interfaceModel[.listenPort] = port

        let host = "\(data[20]).\(data[21]).\(data[22]).\(data[23])"
        tunnelModel.peersModel[0][.endpoint] = "\(host):\(port)"

        let peerPubKeyBytes = data.bytes[26...57]
        let peerPubKeyData = Data(peerPubKeyBytes)
        let peerPubKey = PublicKey(rawValue: peerPubKeyData)
        tunnelModel.peersModel[0][.publicKey] = peerPubKey?.base64Key ?? ""

        upsertTunnel()
        
        return nil
    }

    private func createTunnelService() {
        TunnelsService.create { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                self.delegate?.handleError(error)

            case .success(let tunnelsService):
                self.tunnelsService = tunnelsService
                tunnelsService.refreshStatuses()
                tunnelsService.statusDelegate = self.delegate

                if let tunnel = tunnelsService.tunnels.last {
                    self.tunnelModel = .init(tunnelConfiguration: tunnel.tunnelConfiguration)
                }

                self.prepareTunnelModel()
            }

            self.delegate?.handleTunnelServiceCreation()
        }
    }

    private func prepareTunnelModel() {
        tunnelModel.interfaceModel[.name] = constants.wireguardTunnelName
        if tunnelModel.peersModel.isEmpty {
            tunnelModel.appendEmptyPeer()
        }
        tunnelModel.peersModel[0][.allowedIPs] = constants.allowedIPs
        tunnelModel.peersModel[0][.persistentKeepAlive] = constants.persistentKeepAlive
    }

    private func upsertTunnel(startActivation: Bool = true) {
        delegate?.handleTunnelUpdatingStatus()

        switch tunnelModel.save() {
        case .failure(let error):
            delegate?.handleError(error)

        case .success(let tunnelConfiguration):
            guard let tunnel = tunnelsService?.tunnels.last else {
                addTunnel(
                    tunnelConfiguration: tunnelConfiguration,
                    startActivation: startActivation
                )
                return
            }
            modifyTunnel(
                tunnel: tunnel,
                with: tunnelConfiguration,
                startActivation: startActivation
            )
        }
    }

    private func addTunnel(
        tunnelConfiguration: TunnelConfiguration,
        startActivation: Bool
    ) {
        tunnelsService?.add(
            tunnelConfiguration: tunnelConfiguration,
            onDemandEnabled: true
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                self.delegate?.handleError(error)

            case .success(let tunnel):
                guard startActivation else {
                    return
                }

                self.tunnelsService?.startActivation(of: tunnel)
            }
        }
    }

    private func modifyTunnel(
        tunnel: TunnelContainer,
        with tunnelConfiguration: TunnelConfiguration,
        startActivation: Bool
    ) {
        tunnelsService?.modify(
            tunnel: tunnel,
            isOnDemandEnabled: true,
            tunnelConfiguration: tunnelConfiguration
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                self.delegate?.handleError(error)

            case .success(let tunnel):
                guard startActivation && tunnel.status != .restarting else {
                    self.delegate?.handleTunnelReconnection()
                    return
                }
                self.tunnelsService?.startActivation(of: tunnel)
            }
        }
    }
}

// MARK: - XRAY

extension TunnelManager {
    func startXray(from credentials: ConnectionCredentials) -> TunnelsServiceError? {
        guard let uid = credentials.uid else {
            return .emptyCredentials
        }
        UserDefaults.shared.setValue(storage.selectedDNS.addresses, forKey: XConstant.dnsKey)
        if let error = parse(payload: credentials.payload, id: uid) {
            return error
        }
        delegate?.handleTunnelUpdatingStatus()
        tunnelsService?.startXray(onDemandEnabled: true) {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.handleError(error)
                
            case .success(let tunnel):
                self.tunnelsService?.startActivation(of: tunnel)
            }
        }
        return nil
    }

    private func parse(payload: String, id: String) -> TunnelsServiceError? {
        guard let data = Data(base64Encoded: payload), data.bytes.count == 7 else {
            return .emptyCredentials
        }

        let ip = "\(data[0]).\(data[1]).\(data[2]).\(data[3])"
        let port = data.bytes[4...5]
            .withUnsafeBytes { $0.load(as: UInt16.self) }
            .bigEndian

        let network = XNetwork(from: data.bytes[6])

        let user = VMess.User(id: id)
        let vmess = VMess(address: ip, port: Int(port), users: [user])

        let model = XConfigurationModel(vmess: vmess, network: network)
        do {
            try save(model: model)
        } catch {
            log.error(error)
            return .addTunnelFailed(systemError: error)
        }

        return nil
    }

    private func save(model: XConfigurationModel) throws {
        if #available(iOS 16.0, *) {
            let folderURL = XConstant.configDirectory.appending(component: XConfiguration.currentStoreKey)
            if !FileManager.default.fileExists(atPath: folderURL.path(percentEncoded: false)) {
                try FileManager.default.createDirectory(
                    at: folderURL,
                    withIntermediateDirectories: true
                )
            }
            let destinationURL = folderURL.appending(component: "config.json")
            let data = try JSONEncoder().encode(model)
            FileManager.default.createFile(atPath: destinationURL.path(percentEncoded: false), contents: data)
        } else {
            let folderURL = XConstant.configDirectory.appendingPathComponent(XConfiguration.currentStoreKey)
            if !FileManager.default.fileExists(atPath: folderURL.path) {
                try FileManager.default.createDirectory(
                    at: folderURL,
                    withIntermediateDirectories: true
                )
            }
            let destinationURL = folderURL.appendingPathComponent("config.json")
            let data = try JSONEncoder().encode(model)
            FileManager.default.createFile(atPath: destinationURL.path, contents: data)
        }
    }
}
