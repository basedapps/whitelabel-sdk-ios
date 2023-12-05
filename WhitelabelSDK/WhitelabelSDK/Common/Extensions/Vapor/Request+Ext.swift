//
//  Request+Ext.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 10.10.2023.
//

import Vapor

// MARK: - Constants

private struct Constants {
    let key = "SnLnkORrZuzYsEPb"
}
private let constants = Constants()

extension Request {
    func validate() throws {
        guard let xHeader = headers.first(name: "x-key"), constants.key == xHeader else {
            throw Abort(.badRequest, reason: "Invalid env")
        }
        headers.remove(name: "x-key")
    }
}
