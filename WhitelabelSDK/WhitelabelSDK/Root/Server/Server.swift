//
//  Server.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 04.10.2023.
//

import Foundation
import Vapor

final class Server {
    var app: Application
    
    init() {
        #if DEBUG
        app = Application(.development, .shared(.singletonMultiThreadedEventLoopGroup))
        #else
        app = Application(.production, .shared(.singletonMultiThreadedEventLoopGroup))
        #endif
        Config.setup()
        LoggingSystem.bootstrap { VaporLogHandler($0) }
        
        configure(app)
    }
}

extension Server {
    func start(completion: @escaping () -> Void) {
        Task {
            do {
                let api = app.grouped(.init(stringLiteral: ClientConstants.apiPath))
                try api.register(collection: TunnelRouteCollection())
                try api.register(collection: DNSRouteCollection())
                try api.register(collection: StorageRouteCollection())
                try api.register(collection: ProxyRouteCollection())
                try api.register(collection: BlockchainRouteCollection())
                try api.register(collection: PurchasesRouteCollection())
                completion()
                try await app.execute()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func restart() {
        app.shutdown()
        
        app = Application(.development, .shared(.singletonMultiThreadedEventLoopGroup))
        configure(app)
        
        start { log.info("Did restart server") }
    }
}

// MARK: - Private

extension Server {
    private func configure(_ app: Application) {
        app.http.server.configuration.hostname = ClientConstants.host
        app.http.server.configuration.port = ClientConstants.port
        app.http.client.configuration.timeout = .init(connect: .minutes(24), read: nil, write: .hours(24))
        
        let fileMiddleware = try! FileMiddleware(bundle: .main, publicDirectory: "./", defaultFile: "index.html")
        app.middleware.use(fileMiddleware)
        
        app.logger = .init(label: "codes.vapor.application", factory: { VaporLogHandler($0) })
    }
}
