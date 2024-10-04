//
//  ViewController.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 06.10.2023.
//

import UIKit
import WebKit

final class ViewController: UIViewController {
    private let server = Server()
    private var webView: WKWebView!
    private var appWillEnterForegroundTrigger = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        server.start { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.setUpWebView()
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc func appWillEnterForeground() {
        log.info("appWillEnterForeground")
        if appWillEnterForegroundTrigger { server.restart() }
        appWillEnterForegroundTrigger = true
    }
}

// MARK: Private

extension ViewController {
    private func setUpWebView() {
        let webConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = false
        webView.scrollView.backgroundColor = UIColor(red: 0.00, green: 0.02, blue: 0.06, alpha: 1.00)
        webView.backgroundColor = UIColor(red: 0.00, green: 0.02, blue: 0.06, alpha: 1.00)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0, green: 6/255, blue: 16/255, alpha: 1).cgColor,
            UIColor(red: 25/255, green: 31/255, blue: 49/255, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0.0, 0.2, 1.0]
        gradientLayer.frame = view.bounds
        webView.scrollView.layer.insertSublayer(gradientLayer, at: 0)
        webView.isOpaque = false
        
        view = webView
        
        let urlRequest = URLRequest(
            url: URL(string: ("http://" + ClientConstants.host + ":" + "\(ClientConstants.port)" + "/"))!,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
        
        webView.load(urlRequest)
    }
}
