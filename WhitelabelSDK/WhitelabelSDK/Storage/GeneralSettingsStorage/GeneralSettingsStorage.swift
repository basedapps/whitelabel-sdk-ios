//
//  GeneralSettingsStorage.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 18.08.2021.
//

import Foundation
import Accessibility

private enum Keys: String, CaseIterable {
    case dnsKey
}

final class GeneralSettingsStorage {
    private let settingsStorageStrategy: SettingsStorageStrategyType

    init(settingsStorageStrategy: SettingsStorageStrategyType = UserDefaultsStorageStrategy()) {
        self.settingsStorageStrategy = settingsStorageStrategy
    }
}

// MARK: - StoresGeneralInfo

extension GeneralSettingsStorage: StoresGeneralInfo { }

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
