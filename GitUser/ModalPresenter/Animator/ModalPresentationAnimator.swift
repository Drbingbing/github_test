//
//  ModalPresentationAnimator.swift
//  BottomSheet
//
//  Created by drbingbing on 2021/10/21.
//

import Foundation
import UIKit

public class ModalPresentationAnimator: NSObject {
    
    public enum TransitionStyle {
        
        case presentation
        
        case dismissal
        
    }
    
    private let transitionStyle: TransitionStyle
    

    private var feedbackGenerator: UISelectionFeedbackGenerator?
    
    
    public init(transitionStyle: TransitionStyle) {
        self.transitionStyle = transitionStyle
        
        super.init()
        
        if transitionStyle == .presentation {
            feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator?.prepare()
        }
        
    }
    
    private func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from)
        else { return }
        
        let presentable = modalLayoutType(from: transitionContext)
        
        // Calls viewWillAppear and viewWillDisappear
        if presentable?.interactorWithTransition == true {
            fromViewController.beginAppearanceTransition(false, animated: true)
        }
        
        // Present the view in medium position, initially
        let yPos: CGFloat = presentable?.mediumYPos ?? 0.0
        
        // Use modalview as presentedView ifit already exists witin the containerView
        let modalView: UIView = transitionContext.containerView.modalContainerView ?? toViewController.view
        
        // Move presented view offscreen (from the bottom)
        modalView.frame = transitionContext.finalFrame(for: toViewController)
        modalView.frame.origin.y = transitionContext.containerView.frame.height
        
        // Haptic feedback
        if presentable?.isHapticFeedbackEnabled == true {
            feedbackGenerator?.selectionChanged()
        }
        
        ModalAnimator.animate(config: presentable) {
            modalView.frame.origin.y = yPos
        } completion: { [weak self] didComplete in
            if presentable?.interactorWithTransition == true {
                fromViewController.endAppearanceTransition()
            }
            transitionContext.completeTransition(didComplete)
            self?.feedbackGenerator = nil
        }

    }
    
    private func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from)
        else { return }
        
        let presentable = modalLayoutType(from: transitionContext)
        // Calls viewWillAppear and viewWillDisppear
        if presentable?.interactorWithTransition == true {
            toViewController.beginAppearanceTransition(true, animated: true)
        }
        
        let modalView = transitionContext.containerView.modalContainerView ?? fromViewController.view
        
        ModalAnimator.animate(config: presentable) {
            modalView?.frame.origin.y = transitionContext.containerView.frame.height
        } completion: { didComplete in
            fromViewController.view.removeFromSuperview()
            if presentable?.interactorWithTransition == true {
                toViewController.endAppearanceTransition()
            }
            transitionContext.completeTransition(didComplete)
        }
    }
    
    private func modalLayoutType(from context: UIViewControllerContextTransitioning) -> (ModalPresentable & UIViewController)? {
        switch transitionStyle {
        case .presentation:
            return context.viewController(forKey: .to) as? (ModalPresentable & UIViewController)
        case .dismissal:
            return context.viewController(forKey: .from) as? (ModalPresentable & UIViewController)
        }
    }
}

// MARK: - UIViewControllerAnimatedTransitioning Delegate
extension ModalPresentationAnimator: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        guard
            let context = transitionContext,
            let presentable = modalLayoutType(from: context)
        else { return ModalAnimator.defaultTransitionDuration }
        
        return presentable.transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch transitionStyle {
        case .presentation:
            animatePresentation(transitionContext: transitionContext)
        case .dismissal:
            animateDismissal(transitionContext: transitionContext)
        }
    }
    
}
