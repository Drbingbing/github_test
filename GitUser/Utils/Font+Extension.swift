//
//  Font+Extension.swift
//  GitUser
//
//  Created by Bing Bing on 2024/7/31.
//

import UIKit

extension UIFont {
    
    public var bolded: UIFont {
      return self.fontDescriptor.withSymbolicTraits(.traitBold)
        .map { UIFont(descriptor: $0, size: 0.0) } ?? self
    }
    
    public var rounded: UIFont {
        return self.fontDescriptor.withDesign(.rounded)
            .map { UIFont(descriptor: $0, size: 0.0) } ?? self
    }
}
