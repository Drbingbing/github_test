//
//  ModalAnimator.swift
//  BottomSheet
//
//  Created by drbingbing on 2021/10/21.
//

import Foundation
import UIKit

struct ModalAnimator {
    
    static let defaultTransitionDuration: TimeInterval = 0.5
    
    static func animate(
        config: ModalPresentable?,
        animations: @escaping ModalPresentable.AnimationBlock,
        completion: ModalPresentable.AnimationCompeleteBlock?
    ) {
        
        let transitionDuration = config?.transitionDuration ?? defaultTransitionDuration
        
        let springDamping = config?.springDamping ?? 1.0
        
        let animationOptions = config?.transitionAnimationOptions ?? []
        
        UIView.animate(withDuration: transitionDuration,
                       delay: 0,
                       usingSpringWithDamping: springDamping,
                       initialSpringVelocity: 0,
                       options: animationOptions,
                       animations: animations,
                       completion: completion)
    }
}
