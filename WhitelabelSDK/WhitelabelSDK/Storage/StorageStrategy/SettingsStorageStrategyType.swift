//
//  SettingsStorageStrategyType.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 18.08.2021.
//

import Foundation

protocol SettingsStorageStrategyType: AnyObject {
    func object<T: Codable>(ofType type: T.Type, forKey key: String) -> T?

    @discardableResult
    func setObject<T: Codable>(_ object: T, forKey key: String) -> Bool

    func existsObject(forKey key: String) -> Bool

    @discardableResult
    func removeObject(forKey key: String) -> Bool
}
