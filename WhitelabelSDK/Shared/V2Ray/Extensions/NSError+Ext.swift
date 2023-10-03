//
//  NSError+Ext.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation

extension NSError {
    public static func newError(_ message: String) -> NSError {
        NSError(domain: Bundle.appID, code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
