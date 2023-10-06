//
//  TunnelStatus.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 17.06.2021.
//

import Foundation
import NetworkExtension

@objc
enum TunnelStatus: Int {
    case disconnected
    case connecting
    case connected
    case disconnecting
    case reasserting

    case restarting
    case waiting

    init(from status: NEVPNStatus) {
        switch status {
        case .connected:
            self = .connected
        case .connecting:
            self = .connecting
        case .disconnected:
            self = .disconnected
        case .disconnecting:
            self = .disconnecting
        case .reasserting:
            self = .reasserting
        case .invalid:
            self = .disconnected
        @unknown default:
            fatalError()
        }
    }
}
