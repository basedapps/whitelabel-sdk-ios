//
//  XEncryption.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation

// MARK: - XEncryption

public enum XEncryption: String, Identifiable, Codable {
    public var id: Self { self }

    case aes_128_gcm = "aes-128-gcm"
    case chacha20_poly1305 = "chacha20-poly1305"
    case auto = "auto"
    case none = "none"
    case zero = "zero"
}

// MARK: - Static

extension XEncryption {
    public static let vmess: [XEncryption] = [.chacha20_poly1305, .aes_128_gcm, .auto, .none, .zero]
    public static let quic: [XEncryption] = [.chacha20_poly1305, .aes_128_gcm, .none]
}
