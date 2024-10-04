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
        let deviceInfo = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        log.info("iOS: \(deviceInfo)")
        log.info("App version: \(Bundle.appVersion)")
        
        guard let data = LogFile(fullURL: fileURL)?.content.data else { return nil }
        
        let textFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Sentinel.log")
        try? data.write(to: textFile)
        
        return textFile
    }
}
