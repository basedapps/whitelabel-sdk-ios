//
//  ALPN.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation

// MARK: - ALPN

public enum ALPN: String, Identifiable, CaseIterable, Codable {
    public var id: Self { self }

    case h2 = "h2"
    case http1_1 = "http/1.1"
}
