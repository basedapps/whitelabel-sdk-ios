//
//  XHeaderType.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation

// MARK: - XHeaderType

public enum XHeaderType: String, Identifiable, CaseIterable, Codable {
    public var id: Self { self }

    case none = "none"
    case srtp = "srtp"
    case utp = "utp"
    case wechat_video = "wechat-video"
    case dtls = "dtls"
    case wireguard = "wireguard"
}
