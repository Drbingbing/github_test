//
//  ModalPresent+UIViewController.swift
//  BottomSheet
//
//  Created by drbingbing on 2021/10/21.
//

import Foundation
import UIKit

public extension ModalPresentable where Self: UIViewController {
    
    typealias AnimationBlock = () -> Void
    typealias AnimationCompeleteBlock = (Bool) -> Void
    
    
    func modalTransition(to state: ModalPresentationController.PresentationState) {
        presentableViewController?.transition(to: state)
    }
    
    func modalSetNeedLayout() {
        presentableViewController?.setNeedsLayoutUpdate()
    }
    
    func modalPerformUpdates(_ updates: () -> Void) {
        presentableViewController?.performUpdates(updates)
    }
    
    func modalAnimate(_ animation: @escaping AnimationBlock, complete: AnimationCompeleteBlock? = nil) {
        ModalAnimator.animate(config: self, animations: animation, completion: complete)
    }
}
