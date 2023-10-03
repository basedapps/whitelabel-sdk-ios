//
//  Config.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import UIKit
import SwiftyBeaver

let log = SwiftyBeaver.self

public struct Config {
    static func setup() {
        LogsConfig.setupConsole()
        LogsConfig.setupFile()
    }
}

struct LogsConfig {
    static func setupConsole() {
        let console = ConsoleDestination()
        setup(destination: console)
        log.addDestination(console)
    }

    static func setupFile() {
        let file = FileDestination()
        file.logFileMaxSize = 15 * 1024 * 1024
        setup(destination: file)
        log.addDestination(file)
    }
    
    private static func setup(destination: BaseDestination) {
        destination.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
        #if DEBUG
        destination.minLevel = .verbose
        #else
        destination.minLevel = .info
        #endif
    }
}
