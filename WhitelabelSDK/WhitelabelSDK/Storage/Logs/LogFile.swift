//
//  LogFile.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.02.2024.
//

import Foundation

struct LogFile {
    let name: String
    let content: String
    
    let url: URL?
    
    init(name: String, content: String) {
        self.name = name
        self.content = content
        self.url = URL(string: name + content)
    }
    
    init?(baseURL: URL, name: String) {
        let fullURL = baseURL.appendingPathComponent(name)
        guard let content = try? String(contentsOf: fullURL) else {
            return nil
        }
        self.init(name: name, content: content)
    }
    
    init?(fullURL: URL) {
        guard let content = try? String(contentsOf: fullURL) else {
            return nil
        }
        let name = fullURL.lastPathComponent
        self.init(name: name, content: content)
    }
}
