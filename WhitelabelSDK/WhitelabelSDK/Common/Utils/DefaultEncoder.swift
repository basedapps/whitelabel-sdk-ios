//
//  Encoder.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 06.10.2023.
//

import Foundation

enum EncoderError: String, LocalizedError {
    case failedToEncode = "failed_to_encode"
    
    var errorDescription: String? {
        self.rawValue
    }
}

enum DefaultEncoder {
    static func encode(
        model: Codable,
        continuation: CheckedContinuation<String, Error>
    ) {
        do {
            let result = try JSONEncoder().encode(model)
            let string = String(decoding: result, as: UTF8.self)
            continuation.resume(returning: string)
        } catch {
            #warning("TODO: unify errors")
            continuation.resume(throwing: EncoderError.failedToEncode)
        }
    }
}
