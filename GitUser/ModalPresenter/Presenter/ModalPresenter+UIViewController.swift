//
//  ModalPresenter+UIViewController.swift
//  BottomSheet
//
//  Created by drbingbing on 2021/10/22.
//

import Foundation
import UIKit

extension UIViewController: ModalPresenter {
    
    /// A flag that returns true if the topmost view controller in the navigation stack
    /// was presented using the custom PanModal transition
    ///
    /// - Warning: ⚠️ Calling `presentationController` in this function may cause a memory leak. ⚠️
    ///
    /// In most cases, this check will be used early in the view lifecycle and unfortunately,
    /// there's an Apple bug that causes multiple presentationControllers to be created if
    /// the presentationController is referenced here and called too early resulting in
    /// a strong reference to this view controller and in turn, creating a memory leak.
    public var isModalPresentablePresented: Bool {
        return (transitioningDelegate as? ModalPresentationDelegate) != nil
    }
    
    /// Configures a view controller for presentation using the PanModal transition
    ///
    /// - viewController: The view controller to be presented
    /// - sourceView: The view containing the anchor rectangle for the popover.
    /// - sourceRect: The rectangle in the specified view in which to anchor the popover.
    /// - completion: The block to execute after the presentation finishes. You may specify nil for this parameter.
    ///
    /// - Note: sourceView & sourceRect are only required for presentation on an iPad.
    public func sheet(_ viewController: (UIViewController & ModalPresentable),
               sourceView: UIView? = nil,
               sourceRect: CGRect? = nil,
               completion: (() -> Void)? = nil) {
        
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true)
        }
        
        viewController.modalPresentationStyle = .custom
        viewController.modalPresentationCapturesStatusBarAppearance = true
        viewController.transitioningDelegate = ModalPresentationDelegate.default
        
        present(viewController, animated: true, completion: completion)
    }
}
