//
//  NEVPNManager+Ext.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 06.06.2022.
//

import NetworkExtension

extension NEVPNManager {
    var tunnelBundleIdentifier: String? {
        guard let proto = protocolConfiguration as? NETunnelProviderProtocol else {
            return nil
        }
        return proto.providerBundleIdentifier
    }
    
    func isTunnel(withIdentifier bundleIdentifier: String) -> Bool {
        tunnelBundleIdentifier == bundleIdentifier
    }
}
