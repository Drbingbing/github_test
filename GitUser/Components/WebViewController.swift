//
//  WebViewController.swift
//  GitUser
//
//  Created by Bing Bing on 2024/7/31.
//

import WebKit
import BaseToolbox
import UIKit

final class WebViewController: ViewController {
    
    private lazy var webView = WKWebView()
    
    var urlString: String? {
        didSet {
            guard let urlString else { return }
            url = URL(string: urlString)
        }
    }
    
    var url: URL? {
        didSet {
            guard let url else { return }
            webView.load(URLRequest(url: url))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        webView.allowsLinkPreview = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds.inset(by: view.safeAreaInsets)
    }
}

extension WebViewController: ModalPresentable {
    
    var preferredCornerRadius: CGFloat { 20 }
}
