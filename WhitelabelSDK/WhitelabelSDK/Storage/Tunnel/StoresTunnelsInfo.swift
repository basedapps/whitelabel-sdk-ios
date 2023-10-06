//
//  StoresTunnelsInfo.swift
//  BaseVPN
//
//  Created by Lika Vorobeva on 13.10.2021.
//

import Foundation

protocol StoresTunnelsInfo: AnyObject {
    var selectedDNS: DNSServerType { get set }
}
