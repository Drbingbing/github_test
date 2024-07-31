//
//  ModalPresenter.swift
//  BottomSheet
//
//  Created by drbingbing on 2021/10/22.
//

import Foundation
import UIKit

public protocol ModalPresenter: AnyObject {
    
    /// A flag that returns true if the current presented view controller
    /// is using the PanModalPresentationDelegate
    var isModalPresentablePresented: Bool { get }
    
    /// Presents a view controller that conforms to the PanModalPresentable protocol
    func sheet(_ viewController: (ModalPresentable & UIViewController),
               sourceView: UIView?,
               sourceRect: CGRect?,
               completion: (() -> Void)?)
}
