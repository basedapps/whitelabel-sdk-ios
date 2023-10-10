//
//  Request+Ext.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 10.10.2023.
//

import Vapor

// MARK: - Constants

private struct Constants {
    let key = "x-key"
}
private let constants = Constants()

extension Request {
    func validate() throws {
        guard let key = Environment.get(constants.key), let xHeader = headers.first(name: constants.key), key == xHeader else {
            throw Abort(.badRequest, reason: "Invalid env")
        }
        headers.remove(name: constants.key)
    }
}
