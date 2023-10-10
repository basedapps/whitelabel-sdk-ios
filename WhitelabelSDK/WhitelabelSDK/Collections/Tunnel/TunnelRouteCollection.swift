//
//  TunnelRouteCollection.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 10.10.2023.
//

import Vapor
import Combine

// MARK: - Constants

private struct Constants {
    let connectPath: PathComponent = "connect"
    let disconnectPath: PathComponent = "disconnect"
    let statusPath: PathComponent  = "status"
}
private let constants = Constants()

// MARK: - TunnelRouteCollection

final class TunnelRouteCollection {
    enum EventType {
        case statusUpdated
        case error(Error)
    }
    
    private let manager: TunnelManager
    
    private var eventSubject = PassthroughSubject<EventType, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(manager: TunnelManager = .init()) {
        self.manager = manager
        manager.delegate = self
    }
}

// MARK: - RouteCollection

extension TunnelRouteCollection: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post(constants.connectPath, use: createNewSession)
        routes.post(constants.disconnectPath, use: startDeactivationOfActiveTunnel)
        routes.get(constants.statusPath, use: getConnectionStatus)
    }
}

// MARK: - Requests

extension TunnelRouteCollection {
    private func startDeactivationOfActiveTunnel(_ req: Request) async throws -> String {
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            do {
                guard manager.startDeactivationOfActiveTunnel() else {
                    encodeStatus(continuation: continuation)
                    return
                }
                
                eventSubject.first().sink { event in
                    switch event {
                    case .statusUpdated:
                        self.encodeStatus(continuation: continuation)
                    case let .error(error):
                        continuation.resume(throwing: error)
                    }
                }
                .store(in: &cancellables)
            }
        })
    }
    
    private func createNewSession(_ req: Request) async throws -> String {
        try await withCheckedThrowingContinuation({ [weak self] (continuation: CheckedContinuation<String, Error>) in
            guard let self = self else { return }

            do {
                let creds = try req.content.decode(DataRequest<ConnectionCredentials>.self).data
                switch creds.vpnProtocol {
                case .v2ray:
                    if let error = manager.startXray(from: creds) { throw error }
                case .wireguard:
                    if let error = manager.startWireguard(from: creds) { throw error }
                default:
                    log.error("Unsupported protocol")
                    continuation.resume(throwing: Abort(.badRequest))
                }
                
                eventSubject.first().sink { event in
                    switch event {
                    case .statusUpdated:
                        self.encodeStatus(continuation: continuation)
                    case let .error(error):
                        continuation.resume(throwing: error)
                    }
                }
                .store(in: &cancellables)
                
            } catch {
                log.error(error)
                continuation.resume(throwing: Abort(.badRequest))
            }
        })
    }
    
    private func getConnectionStatus(_ req: Request) async throws -> String {
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            encodeStatus(continuation: continuation)
        })
    }
}

// MARK: - Private methods

extension TunnelRouteCollection {
    private func encodeStatus(continuation: CheckedContinuation<String, Error>) {
        let response = TunnelStatusResponse(isConnected: manager.isTunnelActive)
        DefaultEncoder.encode(model: response, continuation: continuation)
    }
}

// MARK: - TunnelManagerDelegate

extension TunnelRouteCollection: TunnelManagerDelegate {
    func handleTunnelUpdatingStatus() {
        eventSubject.send(.statusUpdated)
    }

    func handleError(_ error: Error) {
        eventSubject.send(.error(error))
    }

    func handleTunnelReconnection() {
        handleTunnelUpdatingStatus()
    }

    func handleTunnelServiceCreation() {
        log.info("Tunnel service created.")
    }
}

// MARK: - TunnelsServiceStatusDelegate

extension TunnelRouteCollection: TunnelsServiceStatusDelegate {
    func activationAttemptFailed(for tunnel: TunnelContainer, with error: TunnelActivationError) {
        eventSubject.send(.error(error))
    }

    func activationAttemptSucceeded(for tunnel: TunnelContainer) {
        log.debug("\(tunnel.name) is succesfully attempted activation")
    }

    func activationFailed(for tunnel: TunnelContainer, with error: TunnelActivationError) {
        eventSubject.send(.error(error))
    }

    func activationSucceeded(for tunnel: TunnelContainer) {
        log.debug("\(tunnel.name) is succesfully activated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in eventSubject.send(.statusUpdated) }
    }

    func deactivationSucceeded(for tunnel: TunnelContainer) {
        log.debug("\(tunnel.name) is succesfully deactivated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in eventSubject.send(.statusUpdated) }
    }
}
