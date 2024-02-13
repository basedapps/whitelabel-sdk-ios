//
//  LogsService.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.02.2024.
//

import UIKit
import SwiftyBeaver

struct LogsService {
    static private var fileDestinationURL: URL? {
        log.destinations.compactMap { ($0 as? FileDestination)?.logFileURL }.first
    }
    
    static func getPlainFileURL() -> URL? {
        guard let fileURL = LogsService.fileDestinationURL else { return nil }
        log.info("Device info. iOS: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
        
        guard let data = LogFile(fullURL: fileURL)?.content.data else { return nil }
        
        let textFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Sentinel.log")
        try? data.write(to: textFile)
        
        return textFile
    }
}
