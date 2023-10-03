//
//  VMess.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation

// MARK: - VMess

public struct VMess: Codable {
    public struct User: Codable {
        public var id: String = ""
        public var alterId: Int = 0
        public var security = XEncryption.auto
    }
    public var address: String = ""
    public var port: Int = 443
    public var users: [User] = [User()]
}
