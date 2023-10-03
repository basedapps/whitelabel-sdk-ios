//
//  XConstant.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation
import UniformTypeIdentifiers

@frozen
public enum XConstant {
    private static func createDirectory(at url: URL) -> URL {
        guard FileManager.default.fileExists(atPath: url.path) == false else {
            return url
        }
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
        return url
    }

    public static let homeDirectory: URL = {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Bundle.suiteName) else {
            fatalError("Unable to load shared file path")
        }
        let url = containerURL.appendingPathComponent("Library/Application Support/Xray")
        return XConstant.createDirectory(at: url)
    }()

    public static var assetDirectory: URL {
        if #available(iOS 16.0, *) {
            return XConstant.createDirectory(
                at: XConstant.homeDirectory.appending(component: "assets", directoryHint: .isDirectory)
            )
        } else {
            return XConstant.createDirectory(
                at: XConstant.homeDirectory.appendingPathComponent("assets", isDirectory: true)
            )
        }
    }

    public static var configDirectory: URL {
        if #available(iOS 16.0, *) {
            return XConstant.createDirectory(
                at: XConstant.homeDirectory.appending(component: "configs", directoryHint: .isDirectory)
            )
        } else {
            return XConstant.createDirectory(
                at: XConstant.homeDirectory.appendingPathComponent("configs", isDirectory: true)
            )
        }
    }
}

extension XConstant {
    public static var dnsKey = "DNS"
    public static var dns: [String] {
        UserDefaults.shared.stringArray(forKey: dnsKey) ?? ["8.8.8.8", "114.114.114.114"]
    }
}
