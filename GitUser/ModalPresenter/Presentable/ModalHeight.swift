//
//  ModalHeight.swift
//  BottomSheet
//
//  Created by drbingbing on 2021/10/21.
//

import UIKit


/// An enum that defines the possible states of the height of a pan modal container view
/// for a given presentation state (medium, large)
public enum ModalHeight {
    
    /// Set the height to be the maximum height + (topOffset)
    case maxHeight
    
    /// Sets the height to be the max height with a specified top inset.
    /// - Note: A value of 0 is equivalent to .maxHeight
    case maxHeightWithTopInset(CGFloat)
    
    /// Set the height to be specified content height
    case contentHeight(CGFloat)
    
    
    /// Sets the height to be the specified content height
    /// & also ignores the bottomSafeAreaInset
    case contentHeightIgnoringSafeArea(CGFloat)
    
    /// Sets the height to be the intrinsic content height
    case intrinsicHeight
}
