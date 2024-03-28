//
//  GeneralSettingsStorage.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 18.08.2021.
//

import Foundation
import Accessibility

private enum Keys: String, CaseIterable {
    case hostKey
    case portKey
    case dnsKey
    case walletKey
}

final class GeneralSettingsStorage {
    private let settingsStorageStrategy: SettingsStorageStrategyType

    init(settingsStorageStrategy: SettingsStorageStrategyType = UserDefaultsStorageStrategy()) {
        self.settingsStorageStrategy = settingsStorageStrategy
    }
}

// MARK: - StoresGeneralInfo

extension GeneralSettingsStorage: StoresGeneralInfo {
    var host: String {
        settingsStorageStrategy.object(ofType: String.self, forKey: Keys.hostKey.rawValue) ?? "grpc.dvpn.me"
    }
    
    func set(host: String) {
        settingsStorageStrategy.setObject(host, forKey: Keys.hostKey.rawValue)
    }
    
    var port: Int {
        settingsStorageStrategy.object(ofType: Int.self, forKey: Keys.portKey.rawValue) ?? 9090
    }
    
    func set(port: Int) {
        settingsStorageStrategy.setObject(port, forKey: Keys.portKey.rawValue)
    }
    
    func set(wallet: String?) {
        settingsStorageStrategy.setObject(wallet, forKey: Keys.walletKey.rawValue)
    }
    
    var walletAddress: String? {
        settingsStorageStrategy.object(ofType: String.self, forKey: Keys.walletKey.rawValue)
    }
}

// MARK: - StoresTunnelsInfo

extension GeneralSettingsStorage: StoresTunnelsInfo {
    var selectedDNS: DNSServerType {
        get {
            settingsStorageStrategy.object(ofType: DNSServerType.self, forKey: Keys.dnsKey.rawValue) ?? .default
        }
        set {
            settingsStorageStrategy.setObject(newValue, forKey: Keys.dnsKey.rawValue)
        }
    }
}

// MARK: - DependencyKey

extension GeneralSettingsStorage {
    static var liveValue = GeneralSettingsStorage()
}
