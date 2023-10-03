//
//  XConstant+Ext.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 12.05.2023.
//

import Foundation

extension XConstant {
    static var cachesDirectory: URL {
        if #available(iOS 16.0, *) {
            return URL(
                filePath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            )
        } else {
            return URL(
                fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            )
        }
    }
}
