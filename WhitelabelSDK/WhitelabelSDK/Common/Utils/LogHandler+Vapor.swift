//
//  LogHandler+Vapor.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.02.2024.
//

import Logging
import SwiftyBeaver
import Vapor

struct VaporLogHandler: Logging.LogHandler {
    let label: String
    var metadata: Logger.Metadata
    var logLevel: Logger.Level
    
    init(
        _ label: String,
        level: Logger.Level = .debug,
        metadata: Logger.Metadata = [:]
    ) {
        self.label = label
        self.metadata = metadata
        self.logLevel = level
    }
    
    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { self.metadata[key] }
        set(newValue) { self.metadata[key] = newValue }
    }
    
    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        let formattedMessage = "\(source.isEmpty ? "\(message)" : "[\(source)] ")\(message)"
        
        switch level {
        case .trace:
            SwiftyBeaver.verbose(formattedMessage, file: file, function: function, line: Int(line), context: metadata)
            
        case .debug:
            SwiftyBeaver.debug(formattedMessage, file: file, function: function, line: Int(line), context: metadata)
            
        case .info:
            SwiftyBeaver.info(formattedMessage, file: file, function: function, line: Int(line), context: metadata)
            
        case .notice, .warning:
            SwiftyBeaver.warning(formattedMessage, file: file, function: function, line: Int(line), context: metadata)
            
        case .error, .critical:
            SwiftyBeaver.error(formattedMessage, file: file, function: function, line: Int(line), context: metadata)
        }
    }
}
