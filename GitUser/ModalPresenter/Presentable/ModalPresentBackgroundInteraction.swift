//
//  ModalPresentBackgroundInteraction.swift
//  Recruit
//
//  Created by drbingbing on 2021/11/24.
//  Copyright © 2021 Daniel. All rights reserved.
//

import Foundation

public enum ModalPresentBackgroundInteraction: Equatable {
    
    /// Taps dismiss the modal immediately
    case dismiss
    
    /// Touches are forwarded to the lower window (In most cases it would be the application main window handle it
    case forward
    
    /// Absorbs touchs. The modal does notings (Swallows the touch)
    case absorbs
}
