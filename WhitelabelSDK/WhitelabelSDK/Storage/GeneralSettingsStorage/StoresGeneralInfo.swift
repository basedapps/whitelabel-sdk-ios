//
//  StoresGeneralInfo.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 13.10.2021.
//

import Foundation

protocol StoresGeneralInfo { 
    func set(wallet: String?)
    var walletAddress: String? { get }
}
