//
//  BlockchainRouteCollection.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 19.10.2023.
//

import Vapor
import SentinelWallet
import HDWallet

// MARK: - Constants

private struct Constants {
    let path: PathComponent = "blockchain"
    
    let walletKey = "wallet"
    let mnemonicsCount = [12, 24]
    
    let defaultLimit: UInt64 = 10
    let defaultOffset: UInt64 = 0
}
private let constants = Constants()

// MARK: - DNSRouteCollection

struct BlockchainRouteCollection {
    private let nodesProvider: AsyncNodesProviderType
    private let signer: TransactionSignerServiceType
    private let commonStorage: StoresGeneralInfo
    private let safeStorage: SettingsStorageStrategyType
    
    init(
        nodesProvider: AsyncNodesProviderType = AsyncNodesProvider(),
        signer: TransactionSignerServiceType = TransactionSignerService(),
        commonStorage: StoresGeneralInfo = GeneralSettingsStorage(),
        safeStorage: SettingsStorageStrategyType = KeychainStorageStrategy(serviceKey: "BlockchainRouteCollection")
    ) {
        self.nodesProvider = nodesProvider
        self.signer = signer
        self.commonStorage = commonStorage
        self.safeStorage = safeStorage
    }
}

// MARK: - RouteCollection

extension BlockchainRouteCollection: RouteCollection  {
    func boot(routes: RoutesBuilder) throws {
        routes.post(constants.path, "endpoint", use: changeEndpoint)
        
        routes.get(constants.path, "nodes", use: getAvailableNodes)
        routes.get(constants.path, "plans", use: getAvailablePlans)
        routes.get(constants.path, "plans", ":id", "nodes", use: getAvailableNodesForPlan)
        
        routes.get(constants.path, "wallet", use: getWalletAddress)
        routes.post(constants.path, "wallet", use: storeWallet)
    }
}

// MARK: - Requests: grpc endpoint

private extension BlockchainRouteCollection {
    func changeEndpoint(_ req: Request) async throws -> Response {
        let body = try req.content.decode(PostEndpointRequest.self)
        nodesProvider.set(host: body.host, port: body.port)
        return Response(status: .ok)
    }
}

// MARK: - Requests: Nodes

private extension BlockchainRouteCollection {
    func getAvailableNodes(_ req: Request) async throws -> [String] {
        try req.validate()
        let limit = req.query[UInt64.self, at: PaginationKeys.limit.rawValue] ?? constants.defaultLimit
        let offset = req.query[UInt64.self, at: PaginationKeys.offset.rawValue] ?? constants.defaultOffset
        return try await nodesProvider.getActiveNodes(limit: limit, offset: offset)
    }   
    
    func getAvailablePlans(_ req: Request) async throws -> [String] {
        try req.validate()
        let limit = req.query[UInt64.self, at: PaginationKeys.limit.rawValue] ?? constants.defaultLimit
        let offset = req.query[UInt64.self, at: PaginationKeys.offset.rawValue] ?? constants.defaultOffset
        return try await nodesProvider.getPlans(limit: limit, offset: offset)
    }
    
    func getAvailableNodesForPlan(_ req: Request) async throws -> [String] {
        try req.validate()
        let limit = req.query[UInt64.self, at: PaginationKeys.limit.rawValue] ?? constants.defaultLimit
        let offset = req.query[UInt64.self, at: PaginationKeys.offset.rawValue] ?? constants.defaultOffset
        guard let id = req.parameters.get("id", as: UInt64.self) else { throw Abort(.badRequest) }
        return try await nodesProvider.getActiveNodes(for: id, limit: limit, offset: offset)
    }
}

// MARK: - Requests: Wallet storage

private extension BlockchainRouteCollection {
    func getWalletAddress(_ req: Request) async throws -> String {
        guard let address = walletAddress else { throw Abort(.notFound) }
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            DefaultEncoder.encode(model: WalletAddressResponse(address: address), continuation: continuation)
        })
    }
    
    func storeWallet(_ req: Request) async throws -> Response {
        let body = try req.content.decode(PostWalletRequest.self)
        let mnemonic = body.mnemonic.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
        guard
            constants.mnemonicsCount.contains(mnemonic.count),
            mnemonic.allSatisfy({ WordList.english.words.contains($0) })
        else {
            throw Abort(.badRequest)
        }
        guard let wallet = signer.restoreAddress(for: mnemonic) else { throw Abort(.badRequest) }
        safeStorage.setObject(mnemonic, forKey: constants.walletKey)
        commonStorage.set(wallet: wallet)
        return .init(status: .ok)
    }
}

// MARK: - Wallet data

extension BlockchainRouteCollection {
    private var walletAddress: String? {
        commonStorage.walletAddress
    }
    
    private func sender(for chain: String) -> TransactionSender? {
        guard let account = walletAddress, let mnemonic = loadMnemonic() else {
            return nil
        }
        return .init(owner: account, ownerMnemonic: mnemonic, chainID: chain)
    }
    
    private func loadMnemonic() -> [String]? {
        guard let account = walletAddress else { return nil }
        return safeStorage.object(ofType: String.self, forKey: constants.walletKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: " ")
    }
}
