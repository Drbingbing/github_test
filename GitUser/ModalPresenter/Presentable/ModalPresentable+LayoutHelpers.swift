//
//  ModalPresentable+LayoutHelpers.swift
//  BottomSheet
//
//  Created by drbingbing on 2021/10/21.
//

import Foundation
import UIKit

extension ModalPresentable where Self: UIViewController {
    
    var presentableViewController: ModalPresentationController? {
        return presentationController as? ModalPresentationController
    }
    
    var topLayoutOffset: CGFloat {
        guard let rootVC = rootViewController else {
            return 0
        }
        
        return rootVC.view.safeAreaInsets.top
    }
    
    var bottomLayoutOffset: CGFloat {
        
        guard let rootVC = rootViewController else {
            return 0
        }
        
        return rootVC.view.safeAreaInsets.bottom
    }
    
    var mediumYPos: CGFloat {
        guard !UIAccessibility.isVoiceOverRunning else {
            return largeYPos
        }
        
        let mediumYPos = topMargin(from: mediumHeight) + topOffset
        return max(mediumYPos, largeYPos)
    }
    
    var largeYPos: CGFloat {
        max(topMargin(from: largeHeight), topMargin(from: mediumHeight)) + topOffset
    }
    
    var bottomYPos: CGFloat {
        guard let container = presentableViewController?.containerView else {
            return view.bounds.height
        }
        
        return container.bounds.size.height - topOffset
    }
    
    func topMargin(from: ModalHeight) -> CGFloat {
        switch from {
        case .maxHeight:
            return 0.0
        case .maxHeightWithTopInset(let inset):
            return inset
        case .contentHeight(let height):
            return bottomYPos - (height + bottomLayoutOffset)
        case .contentHeightIgnoringSafeArea(let height):
            return bottomYPos - height
        case .intrinsicHeight:
            view.layoutIfNeeded()
            let targetSize = CGSize(width: (presentableViewController?.containerView?.bounds ?? UIScreen.main.bounds).width,
                                    height: UIView.layoutFittingCompressedSize.height)
            let intrinsicHeight = view.systemLayoutSizeFitting(targetSize).height
            return bottomYPos - (intrinsicHeight + bottomLayoutOffset)
        }
    }
    
    private var rootViewController: UIViewController? {
        self.view.window?.rootViewController ?? self
    }
}
