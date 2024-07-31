//
//  UIScrollView+Extension.swift
//  GitUser
//
//  Created by Bing Bing on 2024/7/31.
//

import UIKit

extension UIScrollView {
    
    func isNearBottomEdge(edgeOffset: CGFloat = 40.0) -> Bool {
        if self.contentSize == .zero {
            return false
        }
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}
