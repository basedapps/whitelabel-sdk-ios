//
//  NEVPNStatus+Ext.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 17.06.2021.
//

import Foundation
import NetworkExtension

extension NEVPNStatus {
    var description: String {
        switch self {
        case .connected:
            return "connected"
        case .connecting:
            return "connecting"
        case .disconnected:
            return "disconnected"
        case .disconnecting:
            return "disconnecting"
        case .invalid:
            return "invalid"
        case .reasserting:
            return "reasserting"
        @unknown default:
            return "@unknown default"
        }
    }
}
