//
//  ModalPresentable+Default.swift
//  BottomSheet
//
//  Created by drbingbing on 2021/10/22.
//

import Foundation
import UIKit


extension ModalPresentable where Self: UIViewController {
    
    public var modalScrollView: UIScrollView? {
        return nil
    }
    
    public var topOffset: CGFloat {
        return topLayoutOffset + 21.0
    }
    
    public var mediumHeight: ModalHeight {
        return largeHeight
    }
    
    public var largeHeight: ModalHeight {
        guard let scrollView = modalScrollView
        else { return .maxHeight }
        
        // called once during presentation and stored
        scrollView.layoutIfNeeded()
        return .contentHeight(scrollView.contentSize.height)
    }
    
    public var preferredCornerRadius: CGFloat {
        return 10
    }
    
    public var springDamping: CGFloat {
        return 0.8
    }
    
    public var transitionDuration: Double {
        return ModalAnimator.defaultTransitionDuration
    }
    
    public var transitionAnimationOptions: UIView.AnimationOptions {
        return [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]
    }
    
    public var modalBackgroundColor: UIColor {
        return .black.withAlphaComponent(0.7)
    }
    
    public var grabberColor: UIColor {
        return .lightGray
    }
    
    public var prefersGrabberVisible: Bool {
        return true
    }
    
    public var isHapticFeedbackEnabled: Bool {
        return true
    }
    
    public var isUserInteractionEnabled: Bool {
        return true
    }
    
    public var isPresentableInPresentation: Bool {
        return false
    }
    
    public var backgroundInteraction: ModalPresentBackgroundInteraction {
        return .dismiss
    }
    
    public var anchorModalToLarge: Bool {
        return true
    }
    
    public var allowsExtendedScrolling: Bool {
        guard let scrollView = modalScrollView
        else { return false }
        
        scrollView.layoutIfNeeded()
        return scrollView.contentSize.height > (scrollView.frame.height - bottomLayoutOffset)
    }
    
    public var interactorWithTransition: Bool { return true }
    
    public func shouldRespond(to modalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return true
    }
    
    public func shouldPrioritize(modalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return false
    }
    
    public func shouldTransition(to state: ModalPresentationController.PresentationState) -> Bool {
        return true
    }
    
    public func willTransition(to state: ModalPresentationController.PresentationState) {
        
    }
    
    public func modalWillDismiss() {
        
    }
    
    public func modalDidDismiss() {
        
    }
    
    
    
    
}
