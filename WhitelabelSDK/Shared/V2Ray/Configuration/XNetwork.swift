//
//  XNetwork.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation

// MARK: - XNetwork

public enum XNetwork: String, Identifiable, CaseIterable, Codable {
    public var id: Self { self }

    case tcp
    case kcp
    case ws
    case http
    case quic
    case grpc

    init(from byte: UInt8) {
        switch byte {
        case 1:
            self = .tcp
        case 2:
            self = .kcp
        case 3:
            self = .ws
        case 4:
            self = .http
        case 6:
            self = .quic
        case 8:
            self = .grpc
        default:
            log.error("Unsupported XNetwork type \(byte) found. Fallback to default.")
            self = .tcp
        }
    }
}
