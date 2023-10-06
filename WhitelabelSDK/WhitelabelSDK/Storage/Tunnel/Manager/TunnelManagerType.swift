//
//  TunnelManagerType.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 30.09.2021.
//

import Foundation
import WireGuardKit

typealias TunnelManagerTypeDelegate = TunnelManagerDelegate & TunnelsServiceStatusDelegate

protocol TunnelManagerType: AnyObject {
    var delegate: TunnelManagerTypeDelegate? { get set }
    
    var lastTunnel: TunnelContainer? { get }
    
    var isTunnelActive: Bool { get }
    
    @discardableResult
    func startDeactivationOfActiveTunnel() -> Bool
    
    func startActivation(of tunnel: TunnelContainer)
    
    func startDeactivation(of tunnel: TunnelContainer)
    
    func startWireguard(from credentials: ConnectionCredentials) -> TunnelsServiceError?
    func startXray(from credentials: ConnectionCredentials) -> TunnelsServiceError?
    
    func update(with server: String)
    
    func resetVPNConfiguration(completion: @escaping (TunnelsServiceError?) -> Void)
}
