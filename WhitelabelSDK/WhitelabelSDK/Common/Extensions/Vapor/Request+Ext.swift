//
//  Request+Ext.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 10.10.2023.
//

import Vapor

// MARK: - Constants

private struct Constants {
    static let key = "x-key"
    static let rawXKey = Environment.get(Constants.key)
}
private let constants = Constants()

extension Request {
    func validate() throws {
        guard let key = Constants.rawXKey, let xHeader = headers.first(name: Constants.key), key == xHeader else {
            throw Abort(.badRequest, reason: "Invalid env")
        }
        headers.remove(name: Constants.key)
    }
}
