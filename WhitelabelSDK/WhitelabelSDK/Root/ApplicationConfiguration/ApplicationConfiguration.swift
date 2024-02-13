//
//  ApplicationConfiguration.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 21.07.2023.
//

import Vapor

// MARK: - ApplicationConfigurationType

protocol ApplicationConfigurationType {
    var backendURL: URL { get }
}

// MARK: - ApplicationConfiguration

final class ApplicationConfiguration {
    let backendURLString: String
    
    private(set) static var shared = ApplicationConfiguration()

    init() {
        guard let backendURL = Environment.get("backendURL") else {
            fatalError("Misconfigured env: missing backendURL string")
        }
        self.backendURLString = backendURL
    }
}

// MARK: - ApplicationConfigurationType

extension ApplicationConfiguration: ApplicationConfigurationType {
    var backendURL: URL {
        URL(string: backendURLString)!
    }
}
