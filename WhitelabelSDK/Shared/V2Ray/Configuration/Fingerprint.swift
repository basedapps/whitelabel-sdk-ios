//
//  Fingerprint.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation

// MARK: - Fingerprint

public enum Fingerprint: String, Identifiable, CaseIterable, Codable {
    public var id: Self { self }

    case chrome = "chrome"
    case firefox = "firefox"
    case safari = "safari"
    case ios = "ios"
    case android = "android"
    case edge = "edge"
    case _360 = "360"
    case qq = "qq"
    case random = "random"
    case randomized = "randomized"
}
