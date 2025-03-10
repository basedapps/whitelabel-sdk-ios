//
//  AppDelegate.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 06.10.2023.
//

import UIKit
import BranchSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            if let error = error {
                log.error("Branch Error: \(error.localizedDescription)")
            }
            guard let params = params as? [String: AnyObject] else {
                log.info("Branch: no parameters found")
                return
            }
            if let invite = params["u"] as? String {
                UserDefaults.standard.set(invite, forKey: "u")
            }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
