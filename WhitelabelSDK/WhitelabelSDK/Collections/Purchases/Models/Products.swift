//
//  Products.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 06.08.2024.
//

import Foundation
import Vapor
import RevenueCat

struct CurrentOffering: Content {
    let identifier: String
    let packages: [PackageModel]
    
    init(identifier: String, packages: [PackageModel]) {
        self.identifier = identifier
        self.packages = packages
    }
    
    init(offering: Offering) {
        self.identifier = offering.identifier
        self.packages = offering.availablePackages.map(PackageModel.init)
    }
}

struct PackageModel: Content {
    let identifier: String
    let localizedPriceString: String
    
    init(identifier: String, localizedPriceString: String) {
        self.identifier = identifier
        self.localizedPriceString = localizedPriceString
    }
    
    init(package: Package) {
        self.identifier = package.identifier
        self.localizedPriceString = package.localizedPriceString
    }
}

struct StoreTransactionResultModel: Content {
    let isCancelled: Bool
    let transaction: StoreTransactionModel?
    
    init(isCancelled: Bool, transaction: StoreTransactionModel?) {
        self.isCancelled = isCancelled
        self.transaction = transaction
    }
    
    init(result: PurchaseResultData) {
        self.isCancelled = result.userCancelled
        self.transaction = StoreTransactionModel(storeTransaction: result.transaction)
    }
}


struct StoreTransactionModel: Content {
    let productIdentifier: String
    let purchaseDate: Date
    let transactionIdentifier: String
    
    init(productIdentifier: String, purchaseDate: Date, transactionIdentifier: String) {
        self.productIdentifier = productIdentifier
        self.purchaseDate = purchaseDate
        self.transactionIdentifier = transactionIdentifier
    }
    
    init?(storeTransaction: StoreTransaction?) {
        guard let storeTransaction = storeTransaction else { return nil }
        self.productIdentifier = storeTransaction.productIdentifier
        self.purchaseDate = storeTransaction.purchaseDate
        self.transactionIdentifier = storeTransaction.transactionIdentifier
    }
}
