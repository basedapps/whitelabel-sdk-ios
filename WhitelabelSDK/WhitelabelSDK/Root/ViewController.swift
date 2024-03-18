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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        server.start { [weak self] in
            DispatchQueue.main.async {
                self?.setUpWebView()
            }
        }
    }
}

// MARK: Private

extension ViewController {
    private func setUpWebView() {
        let webConfiguration = WKWebViewConfiguration()
        
        webConfiguration.setValue(true, forKey: "_allowUniversalAccessFromFileURLs")
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = false
        view = webView
        
        let urlRequest = URLRequest(
            url: URL(string: ("http://" + ClientConstants.host + ":" + "\(ClientConstants.port)" + "/"))!,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
        
        webView.load(urlRequest)
    }
}
