//
//  ContainerView.swift
//  BottomSheet
//
//  Created by drbingbing on 2021/10/21.
//

import Foundation
import UIKit

class ModalContainerView: UIView {
    
    init(presentedView: UIView, frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(presentedView)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension UIView {
    
    /**
     Convenience property for retrieving a PanContainerView instance
     from the view hierachy
     */
    var modalContainerView: ModalContainerView? {
        return subviews.first(where: { view -> Bool in
            view is ModalContainerView
        }) as? ModalContainerView
    }
    
}
