//
//  ModalPresentationDelegate.swift
//  BottomSheet
//
//  Created by drbingbing on 2021/10/21.
//

import Foundation
import UIKit

public class ModalPresentationDelegate: NSObject {
    
    /// Returns an instance of the delegate, retained for the duration of presentation
    public static var `default`: ModalPresentationDelegate = {
        return ModalPresentationDelegate()
    }()
    
}

extension ModalPresentationDelegate: UIViewControllerTransitioningDelegate {
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalPresentationAnimator(transitionStyle: .dismissal)
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalPresentationAnimator(transitionStyle: .presentation)
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        controller.delegate = self
        return controller
    }
}

extension ModalPresentationDelegate: UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    
    /// We do not adapt to size classes due to the introduction of the UIPresentationController
    /// & deprecation of UIPopoverController (iOS 9), there is no way to have more than one
    /// presentation controller in use during the same presentation
    ///
    /// This is essential when transitioning from .popover to .custom on iPad split view...
    /// unless a custom popover view is also implemented
    /// (popover uses UIPopoverPresentationController & we use PanModalPresentationController)
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    
}
