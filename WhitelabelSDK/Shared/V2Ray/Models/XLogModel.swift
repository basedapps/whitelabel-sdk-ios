//
//  XLogModel.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 13.07.2023.
//

import Foundation

// MARK: - XConstant: log

extension XConstant {
    public static let log: String = "XRAY_LOG_DATA"
}

// MARK: - XLogModel

public struct XLogModel: Codable, Equatable {
    public let accessLogEnabled: Bool
    public let dnsLogEnabled: Bool
    public let errorLogSeverity: Severity
}

// MARK: - Static properties

extension XLogModel {
    public static let `default` = XLogModel(
        accessLogEnabled: false,
        dnsLogEnabled: false,
        errorLogSeverity: .unknown
    )
    
    public static var current: XLogModel {
        do {
            guard let data = UserDefaults.shared.data(forKey: XConstant.log) else {
                return .default
            }
            return try JSONDecoder().decode(XLogModel.self, from: data)
        } catch {
            return .default
        }
    }
}

// MARK: - Submodels

extension XLogModel {
    public enum Severity: String, Codable, Equatable, CaseIterable, Identifiable {
        public var id: Self { self }
        case unknown = "Unknown"
        case error = "Error"
        case warning = "Warning"
        case info = "Info"
        case debug = "Debug"
    }
}
