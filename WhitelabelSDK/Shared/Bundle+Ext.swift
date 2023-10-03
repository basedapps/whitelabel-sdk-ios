//
//  Bundle+Ext.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation

extension Bundle {
    public static var appID: String {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            fatalError("Unknown bundleIdentifier")
        }
        return bundleIdentifier
    }
    
    public static var suiteName: String {
        "group." + appID
    }

    public static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }

    public static var providerBundleIdentifier: String {
       appID + ".v2ray-ne"
    }
}
