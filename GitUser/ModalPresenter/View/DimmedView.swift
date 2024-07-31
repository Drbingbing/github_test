//
//  DimmedView.swift
//  BottomSheet
//
//  Created by drbingbing on 2021/10/21.
//

import UIKit

public class DimmedView: UIView {
    
    enum DimState {
        
        case max
        case off
        case percent(CGFloat)
        
    }
    
    var dimState: DimState = .off {
        didSet {
            switch dimState {
            case .max:
                alpha = 1.0
            case .off:
                alpha = 0.0
            case .percent(let percentage):
                alpha = max(0, min(1.0, percentage))
            }
        }
    }
    
    
    var hitTestHandler: ((_ point: CGPoint, _ event: UIEvent?) -> UIView?)?
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return hitTestHandler?(point, event) ?? super.hitTest(point, with: event)
    }
    
    public init(dimColor: UIColor = UIColor.black.withAlphaComponent(0.7)) {
        super.init(frame: .zero)
        
        alpha = 0.0
        backgroundColor = dimColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
