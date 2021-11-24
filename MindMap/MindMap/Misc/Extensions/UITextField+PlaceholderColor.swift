//
//  UITextField.swift
//  MindMap
//
//

import UIKit

extension UITextField {
    @IBInspectable var placeholderColor: UIColor {
        
        get {
            guard let currentAttributedPlaceholderColor =
                    attributedPlaceholder?.attribute(NSAttributedString.Key.foregroundColor,
                                                     at: 0, effectiveRange: nil) as? UIColor else {
                return UIColor.clear
            }
            return currentAttributedPlaceholderColor
        }
        
        set {
            guard let currentAttributedString = attributedPlaceholder else { return }
            let attributes = [NSAttributedString.Key.foregroundColor: newValue]
            
            attributedPlaceholder = NSAttributedString(string: currentAttributedString.string, attributes: attributes)
        }
        
    }
    
}
