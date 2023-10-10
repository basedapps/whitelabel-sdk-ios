//
//  StorageRouteCollection.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 06.10.2023.
//

import Vapor

// MARK: - Constants

private struct Constants {
    let path: PathComponent = "registry"
}
private let constants = Constants()

// MARK: - StorageRouteCollection

struct StorageRouteCollection {
    private let commonStorage: SettingsStorageStrategyType
    private let safeStorage: SettingsStorageStrategyType
    
    init(
        commonStorage: SettingsStorageStrategyType = UserDefaultsStorageStrategy(),
        safeStorage: SettingsStorageStrategyType = KeychainStorageStrategy(serviceKey: "CommunityCoreSafeStorage")
    ) {
        self.commonStorage = commonStorage
        self.safeStorage = safeStorage
    }
}

// MARK: - RouteCollection

extension StorageRouteCollection: RouteCollection  {
    func boot(routes: RoutesBuilder) throws {
        routes.get(constants.path, use: getValue)
        routes.post(constants.path, use: postValue)
        routes.delete(constants.path, use: deleteValue)
    }
}

// MARK: - Requests

extension StorageRouteCollection {
    private func getValue(_ req: Request) async throws -> String {
        guard let key = req.query[String.self, at: LocalValue.CodingKeys.key.rawValue] else {
            throw Abort(.badRequest)
        }
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            do {
                let body = try getValue(for: key)
                DefaultEncoder.encode(model: body, continuation: continuation)
            } catch {
                continuation.resume(throwing: error)
            }
        })
    }
    
    private func postValue(_ req: Request) async throws -> Response {
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Response, Error>) in
            do {
                let value = try req.content.decode(LocalValue.self)
                guard deleteValue(for: value.key) else { throw Abort(.unauthorized) }
                
                guard getStorage(isSecure: value.isSecure).setObject(value.value, forKey: value.key) else {
                    throw Abort(.internalServerError)
                }
                
                continuation.resume(returning: .init(status: .ok))
            } catch {
                continuation.resume(throwing: error)
            }
        })
    }
    
    private func deleteValue(_ req: Request) async throws -> Response {
        guard let key = req.query[String.self, at: LocalValue.CodingKeys.key.rawValue] else { throw Abort(.badRequest) }
        guard deleteValue(for: key) else { throw Abort(.unauthorized) }
        
        return .init(status: .ok)
    }
}

// MARK: - Private methods

extension StorageRouteCollection {
    private var storages: [SettingsStorageStrategyType] {
        [commonStorage, safeStorage]
    }
    
    private func getStorage(isSecure: Bool) -> SettingsStorageStrategyType {
       isSecure ? safeStorage : commonStorage
    }
    
    private func getValue(for key: String) throws -> LocalValue {
        if let safeObject = safeStorage.object(ofType: String.self, forKey: key) {
            return .init(key: key, value: safeObject, isSecure: true)
        }
        
        if let commonObject = commonStorage.object(ofType: String.self, forKey: key) {
            return .init(key: key, value: commonObject, isSecure: false)
        }
        
        throw Abort(.notFound)
    }
    
    private func deleteValue(for key: String) -> Bool {
        !storages.map { $0.removeObject(forKey: key) }.contains(false)
    }
}
