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
        
        server.start()
        setUpWebView()
    }
}

// MARK: Private

extension ViewController {
    private func setUpWebView() {
        let webConfiguration = WKWebViewConfiguration()
        
        webConfiguration.setValue(true, forKey: "_allowUniversalAccessFromFileURLs")
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = webView
        
        guard let path = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "dist") else {
            log.error("Fail to load UI from resources")
            return
        }
        
        webView.loadFileURL(path, allowingReadAccessTo: path)
    }
}
