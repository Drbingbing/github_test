//
//  ScrollViewBehavior.swift
//  GitUser
//
//  Created by Bing Bing on 2024/7/31.
//

import UIKit
import BaseToolbox

struct ScrollViewBehavior: ViewControllerLifecycleBehavior {
    
    private let coordinator: Coordinator
    private let refreshable: Bool
    
    init(prefetching: @escaping (() -> Void), reloading: (() -> Void)? = nil) {
        self.coordinator = Coordinator(prefetching: prefetching, reloading: reloading)
        self.refreshable = reloading != nil
    }
    
    func viewDidLoad(viewController: UIViewController) {
        if let view = viewController.view.subviews.first(where: { $0 is UIScrollView }) {
            let scrollView = (view as? UIScrollView)
            
            scrollView?.delegate = coordinator
            if refreshable {
                scrollView?.refreshControl = UIRefreshControl().then {
                    $0.tintColor = .primaryTintColor
                    $0.transform = .identity.scaledBy(0.6)
                }
                scrollView?.refreshControl?.addTarget(coordinator, action: #selector(coordinator.didRefreshing), for: .valueChanged)
            }
        }
    }
}

extension ScrollViewBehavior {
    
    private class Coordinator: NSObject, UIScrollViewDelegate {
        
        private let prefetching: (() -> Void)
        private let reloading: (() -> Void)?
        
        init(prefetching: @escaping (() -> Void), reloading: (() -> Void)?) {
            self.prefetching = prefetching
            self.reloading = reloading
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if scrollView.isNearBottomEdge() {
                prefetching()
            }
        }
        
        @objc
        func didRefreshing(_ sender: UIRefreshControl) {
            delay(0.5) {
                sender.endRefreshing()
            }
            
            reloading?()
        }
    }
}
