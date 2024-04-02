//
//  BlockchainRouteCollection.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 19.10.2023.
//

import Vapor
import SentinelWallet
import HDWallet
import WireGuardKit
import GRPC

// MARK: - Constants

private struct Constants {
    let chainHeaderKey = "x-chain-id"
    let gasHeaderKey = "x-gas-prices"
    
    let path: PathComponent = "blockchain"
    
    let walletKey = "wallet"
    let mnemonicsCount = [12, 24]
    
    let defaultLimit: UInt64 = 10
    let defaultOffset: UInt64 = 0
}
private let constants = Constants()

// MARK: - BlockchainRouteCollection

struct BlockchainRouteCollection {
    private let nodesProvider: AsyncNodesProviderType
    private let subscriptionProvider: AsyncSubscriptionsProviderType
    private let transactionProvider: AsyncTransactionProviderType
    
    private let providers: [ConfigurableProvider]
    
    private let signer: TransactionSignerServiceType
    
    private let commonStorage: StoresGeneralInfo
    private let safeStorage: SettingsStorageStrategyType
    
    init(
        nodesProvider: AsyncNodesProviderType & ConfigurableProvider = AsyncNodesProvider(),
        subscriptionProvider: AsyncSubscriptionsProviderType & ConfigurableProvider = AsyncSubscriptionsProvider(),
        transactionProvider: AsyncTransactionProviderType & ConfigurableProvider = AsyncTransactionProvider(),
        signer: TransactionSignerServiceType = TransactionSignerService(),
        commonStorage: StoresGeneralInfo = GeneralSettingsStorage(),
        safeStorage: SettingsStorageStrategyType = KeychainStorageStrategy(serviceKey: "BlockchainRouteCollection")
    ) {
        self.nodesProvider = nodesProvider
        self.subscriptionProvider = subscriptionProvider
        self.transactionProvider = transactionProvider
        self.providers = [nodesProvider, subscriptionProvider, transactionProvider]
        self.signer = signer
        self.commonStorage = commonStorage
        self.safeStorage = safeStorage
        
        let host = commonStorage.host
        let port = commonStorage.port
        providers.forEach { $0.set(host: host, port: port) }
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
        routes.get(constants.path, "keywords", use: generateWallet)
        routes.post(constants.path, "wallet", use: storeWallet)
        
        routes.get(constants.path, "wallet", ":address", "balance", use: getWalletBalance)
        routes.get(constants.path, "wallet", ":address", "subscriptions", use: getWalletSubscriptions)
        
        routes.get(constants.path, "transactions", ":txHash", use: getTransaction)
        routes.post(constants.path, "plans", ":id", "subscription", use: subscribeToPlan)
        routes.post(constants.path, "nodes", ":address", "subscription", use: subscribeToNode)
        routes.post(constants.path, "wallet", ":address", "balance", use: transfer)
        
        routes.get(constants.path, "wallet", ":address", "session", use: getWalletSession)
        routes.post(constants.path, "wallet", ":address", "session", use: startSession)
        
        routes.post(constants.path, "wallet", "connect", use: fetchCredentials)
    }
}

// MARK: - Requests: grpc endpoint

private extension BlockchainRouteCollection {
    func changeEndpoint(_ req: Request) async throws -> Response {
        try req.validate()
        let body = try req.content.decode(PostEndpointRequest.self)
        providers.forEach { $0.set(host: body.host, port: body.port) }
        commonStorage.set(host: body.host)
        commonStorage.set(port: body.port)
        return Response(status: .ok)
    }
}

// MARK: - Requests: Nodes

private extension BlockchainRouteCollection {
    func getAvailableNodes(_ req: Request) async throws -> String {
        try req.validate()
        let limit = req.query[UInt64.self, at: PaginationKeys.limit.rawValue] ?? constants.defaultLimit
        let offset = req.query[UInt64.self, at: PaginationKeys.offset.rawValue] ?? constants.defaultOffset
        return try await nodesProvider.getActiveNodes(limit: limit, offset: offset)
    }   
    
    func getAvailablePlans(_ req: Request) async throws -> String {
        try req.validate()
        let limit = req.query[UInt64.self, at: PaginationKeys.limit.rawValue] ?? constants.defaultLimit
        let offset = req.query[UInt64.self, at: PaginationKeys.offset.rawValue] ?? constants.defaultOffset
        return try await nodesProvider.getPlans(limit: limit, offset: offset)
    }
    
    func getAvailableNodesForPlan(_ req: Request) async throws -> String {
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
        try req.validate()
        guard let address = walletAddress else { throw Abort(.notFound) }
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            DefaultEncoder.encode(model: WalletAddressResponse(address: address), continuation: continuation)
        })
    }
    
    func generateWallet(_ req: Request) async throws -> String {
        try req.validate()
        let keywords = try signer.generateMnemonic().get().1
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            DefaultEncoder.encode(model: KeywordsResponse(keywords: keywords), continuation: continuation)
        })
    }
    
    func storeWallet(_ req: Request) async throws -> Response {
        try req.validate()
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

// MARK: - Requests: Wallet data

private extension BlockchainRouteCollection {
    func getWalletBalance(_ req: Request) async throws -> String {
        try req.validate()
        guard let address = req.parameters.get("address", as: String.self) else { throw Abort(.badRequest) }
        return try await subscriptionProvider.fetchBalance(for: address)
    }
    
    func getWalletSubscriptions(_ req: Request) async throws -> String {
        try req.validate()
        guard let address = req.parameters.get("address", as: String.self) else { throw Abort(.badRequest) }
        let limit = req.query[UInt64.self, at: PaginationKeys.limit.rawValue] ?? constants.defaultLimit
        let offset = req.query[UInt64.self, at: PaginationKeys.offset.rawValue] ?? constants.defaultOffset
        return try await subscriptionProvider.fetchSubscriptions(limit: limit, offset: offset, for: address)
    }  
    
    func getWalletSession(_ req: Request) async throws -> String {
        try req.validate()
        guard let address = req.parameters.get("address", as: String.self) else { throw Abort(.badRequest) }
        guard let result =  try await subscriptionProvider.fetchSessions(for: address) else { throw Abort(.notFound) }
        return result
    }
    
    func fetchCredentials(_ req: Request) async throws -> String {
        try req.validate()
        let body = try req.content.decode(CredentialsRequest.self)
        
        guard var components = URLComponents(string: body.url) else { throw Abort(.badRequest, reason: "Invalid path") }
        components.scheme = "http"
        
        guard let urlString = components.string, let url = URL(string: urlString) else {
            throw Abort(.badRequest, reason: "Invalid path")
        }
        guard let host = url.host() else {
            throw Abort(.badRequest, reason: "Invalid host in env")
        }
        var headers = req.headers
        headers.replaceOrAdd(name: "Host", value: host)
        
        guard let type = ServerProtocol(rawValue: body.nodeProtocol) else {
            throw Abort(.badRequest, reason: "Invalid protocol")
        }
        
        guard let key = type == .v2ray ? generateXRayKey() : generateWGKey() else {
            throw Abort(.badRequest, reason: "Invalid protocol")
        }
        
        guard walletAddress == body.address, let mnemonic = loadMnemonic() else { throw Abort(.unauthorized) }
        
        var int = body.session.bigEndian
        let sessionIdData = Data(bytes: &int, count: 8)

        guard let signature = signer.generateSignature(for: sessionIdData, with: mnemonic) else {
            throw Abort(.unauthorized)
        }
        
        let fullURL: URI = "\(urlString)/accounts/\(body.address)/sessions/\(body.session)"
        
        let response = try await req.client.send(.POST, headers: headers, to: fullURL) { clientReq in
            try clientReq.content.encode(["key": key.publicKey, "signature": signature])
        }
        
        let result = try response.content.decode(StartSessionResponse.self)
        guard result.success, let payload = result.result else {
            throw Abort(response.status, reason: result.error?.message)
        }
        
        let creds: ConnectionCredentials
        
        switch type {
        case .v2ray:
            creds = .init(vpnProtocol: .v2ray, payload: payload, uid: key.privateKey)
        default:
            creds = .init(vpnProtocol: .wireguard, payload: payload, privateKey: key.privateKey)
        }
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
            DefaultEncoder.encode(model: creds, continuation: continuation)
        })
    }
}

// MARK: - Requests: Transactions

private extension BlockchainRouteCollection {
    func getTransaction(_ req: Request) async throws -> String {
        try req.validate()
        guard let hash = req.parameters.get("txHash", as: String.self) else { throw Abort(.badRequest) }
        do {
            return try await transactionProvider.getTx(by: hash)
        } catch {
            guard let statusError = error as? GRPCStatus, statusError.code.rawValue == 5 else {
                throw error
            }
            throw Abort(.notFound)
        }
    }
    
    func subscribeToPlan(_ req: Request) async throws -> String {
        try req.validate()
        let body = try req.content.decode(PlanPaymentDetails.self)
        guard
            let chainHeader = req.headers.first(name: constants.chainHeaderKey),
            let sender = sender(for: chainHeader)
        else {
            throw Abort(.unauthorized)
        }
        
        guard 
            let gasHeader = req.headers.first(name: constants.gasHeaderKey),
                let gas = Int(gasHeader)
        else { 
            throw Abort(.badRequest)
        }
        guard let id = req.parameters.get("id", as: UInt64.self) else { throw Abort(.badRequest) }
        
        return try await transactionProvider.subscribe(sender: sender, plan: id, details: body, fee: .init(for: gas))
    }
    
    func subscribeToNode(_ req: Request) async throws -> String {
        try req.validate()
        let body = try req.content.decode(NodePaymentDetails.self)
        guard
            let chainHeader = req.headers.first(name: constants.chainHeaderKey),
            let sender = sender(for: chainHeader)
        else {
            throw Abort(.unauthorized)
        }
        
        guard 
            let gasHeader = req.headers.first(name: constants.gasHeaderKey),
            let gas = Int(gasHeader)
        else {
            throw Abort(.badRequest)
        }
        guard let address = req.parameters.get("address", as: String.self) else { throw Abort(.badRequest) }
        return try await transactionProvider.subscribe(sender: sender, node: address, details: body, fee: .init(for: gas))
    }
    
    func transfer(_ req: Request) async throws -> String {
        try req.validate()
        let body = try req.content.decode(DirectPaymentDetails.self)
        guard
            let chainHeader = req.headers.first(name: constants.chainHeaderKey),
            let sender = sender(for: chainHeader)
        else {
            throw Abort(.unauthorized)
        }
        
        guard 
            let gasHeader = req.headers.first(name: constants.gasHeaderKey),
            let gas = Int(gasHeader)
        else {
            throw Abort(.badRequest)
        }
        guard let address = req.parameters.get("address", as: String.self) else { throw Abort(.badRequest) }
        
        return try await transactionProvider.transfer(
            sender: sender,
            recipient: address,
            details: body,
            fee: .init(for: gas)
        )
    }
    
    func startSession(_ req: Request) async throws -> String {
        try req.validate()
        let body = try req.content.decode(PostSessionRequest.self)
        guard
            let chainHeader = req.headers.first(name: constants.chainHeaderKey),
            let sender = sender(for: chainHeader)
        else {
            throw Abort(.unauthorized)
        }
        
        guard
            let gasHeader = req.headers.first(name: constants.gasHeaderKey),
            let gas = Int(gasHeader)
        else {
            throw Abort(.badRequest)
        }
        
        guard let address = req.parameters.get("address", as: String.self) else { throw Abort(.badRequest) }
        
        return try await transactionProvider.startSession(
            sender: sender,
            on: body.subscriptionID,
            activeSession: body.activeSession,
            node: body.node,
            fee: .init(for: gas)
        )
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
        safeStorage.object(ofType: [String].self, forKey: constants.walletKey)
    }
    
    private func generateXRayKey() -> (publicKey: String, privateKey: String)? {
        var uid: [UInt8] = [UInt8](repeating: 0, count: 16)

        guard SecRandomCopyBytes(kSecRandomDefault, uid.count, &uid) == errSecSuccess else {
            return nil
        }

        let uuid = NSUUID(uuidBytes: uid).uuidString
        let data = Data(uid)
        let clientKeyData = Data([0x01]) + data
        return (clientKeyData.base64EncodedString(), uuid)
    }

    private func generateWGKey() -> (publicKey: String, privateKey: String) {
        let wgKey = PrivateKey()
        return (wgKey.publicKey.base64Key, wgKey.base64Key)
    }
}
