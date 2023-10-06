//
//  TunnelsServiceStatusDelegate.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 17.06.2021.
//

import Foundation
import WireGuardKit

// MARK: - TunnelsServiceError

enum TunnelsServiceError: LocalizedError {
    case emptyName
    case nameAlreadyExists

    case loadTunnelsFailed(systemError: Error)
    case addTunnelFailed(systemError: Error)
    
    case removeTunnelFailed(systemError: Error)
    
    case emptyCredentials
}

// MARK: - Equatable

extension TunnelsServiceError: Equatable {
    static func == (lhs: TunnelsServiceError, rhs: TunnelsServiceError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}

extension TunnelsServiceError {
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "The name of teh tunnel is empty"
        case .nameAlreadyExists:
            return "The name of the tunnel already exist"
        case .loadTunnelsFailed:
            return "Failed to load a tunnel"
        case .addTunnelFailed:
            return "Failed to add a tunnel"
        case .removeTunnelFailed:
            return "Failed to remove the tunnel"
        case .emptyCredentials:
            return "Failed to parse the connection data"
        }
    }
}

enum TunnelActivationError: LocalizedError {
    case inactive
    case startingFailed(systemError: Error)
    case savingFailed(systemError: Error)
    case loadingFailed(systemError: Error)
    case retryLimitReached(lastSystemError: Error)
    case activationAttemptFailed(wasOnDemandEnabled: Bool)

    var errorDescription: String? {
        switch self {
        case .inactive:
            return "Tunnel is inactive"
        case let .startingFailed(systemError):
            return "Starting failed due to \(systemError.localizedDescription)"
        case let .savingFailed(systemError):
            return "Saving failed due to \(systemError.localizedDescription)"
        case let .loadingFailed(systemError):
            return "Loading failed due to \(systemError.localizedDescription)"
        case let .retryLimitReached(systemError):
            return "Reached the retry limit with \(systemError.localizedDescription)"
        case .activationAttemptFailed:
            return "Failed to activate a tunnel. Check your dns settings and try again"
        }
    }
}

protocol TunnelsServiceStatusDelegate: AnyObject {
    func activationAttemptFailed(for tunnel: TunnelContainer, with error: TunnelActivationError)
    func activationAttemptSucceeded(for tunnel: TunnelContainer)

    func activationFailed(for tunnel: TunnelContainer, with error: TunnelActivationError)
    func activationSucceeded(for tunnel: TunnelContainer)

    func deactivationSucceeded(for tunnel: TunnelContainer)
}
