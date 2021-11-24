//
//  UIScrollView+ViewState.swift
//  APExtensions
//
//  Created by Anton Plebanovich on 12/7/17.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit

// ******************************* MARK: - Responder Helpers

private var flashScrollIndicatorsOnViewDidAppearAssociationKey = 0
private var c_flashScrollIndicatorsNotificationTokenAssociationKey = 0

public extension UIScrollView {
    
    private var _flashScrollIndicatorsOnViewDidAppear: Bool {
        get {
            return objc_getAssociatedObject(self, &flashScrollIndicatorsOnViewDidAppearAssociationKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &flashScrollIndicatorsOnViewDidAppearAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var flashScrollIndicatorsNotificationToken: NSObjectProtocol? {
        get {
            return objc_getAssociatedObject(self, &c_flashScrollIndicatorsNotificationTokenAssociationKey) as? NSObjectProtocol
        }
        set {
            objc_setAssociatedObject(self, &c_flashScrollIndicatorsNotificationTokenAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Tells scroll view to flash its scroll indicators in view did appear. Always.
    @IBInspectable var flashScrollIndicatorsOnViewDidAppear: Bool {
        get {
            return _flashScrollIndicatorsOnViewDidAppear
        }
        set {
            guard newValue != flashScrollIndicatorsOnViewDidAppear else { return }
            
            _flashScrollIndicatorsOnViewDidAppear = newValue
            
            if newValue {
                let becomeFirstResponderOnViewDidAppearClosure: (UIViewController?) -> () = { [weak self] viewController in
                    guard let _self = self, let viewController = viewController, _self._flashScrollIndicatorsOnViewDidAppear else { return }
                    
                    if viewController.viewState == .didAppear {
                        // Already appeared
                        _self.flashScrollIndicators()
                    }
                    
                    // Perform each time on did appear
                    _self.flashScrollIndicatorsNotificationToken = NotificationCenter.default.addObserver(forName: .UIViewControllerViewDidAppear, object: viewController, queue: nil) { _ in
                        guard let _self = self else { return }
                        // Reset this flag so we can assign it again later if needed
                        _self.flashScrollIndicators()
                    }
                }
                
                if let viewController = _viewController {
                    becomeFirstResponderOnViewDidAppearClosure(viewController)
                } else {
                    // No viewController means it's initialization from storyboard. Have to wait.
                    DispatchQueue.main.async {
                        becomeFirstResponderOnViewDidAppearClosure(self._viewController)
                    }
                }
            } else {
                flashScrollIndicatorsNotificationToken.flatMap(NotificationCenter.default.removeObserver)
                flashScrollIndicatorsNotificationToken = nil
            }
        }
    }
}
