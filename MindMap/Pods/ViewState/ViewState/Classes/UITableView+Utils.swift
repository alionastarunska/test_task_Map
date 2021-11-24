//
//  UITableView+Utils.swift
//  ViewState
//
//  Created by Anton Plebanovich on 1/3/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import UIKit

private var c_isWaitingForAttachAssociationKey = 0

public extension UITableView {
    
    private var _isWaitingForAttach: Bool {
        get {
            return objc_getAssociatedObject(self, &c_isWaitingForAttachAssociationKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &c_isWaitingForAttachAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Reload data when `tableView` is in window hierarchy to prevent excessive reloads.
    func reloadDataWhenPossible() {
        if window != nil {
            reloadData()
            return
        }
        
        if _isWaitingForAttach {
            return
        } else {
            _isWaitingForAttach = true
        }
        
        let becomeFirstResponderOnViewDidAppearClosure: (UIViewController?) -> () = { [weak self] viewController in
            guard let _self = self, let viewController = viewController, _self._isWaitingForAttach else { return }
            
            if viewController.viewState.isOneOf(states: [.didAttach, .didAppear, .willDisappear]) {
                // Already appeared
                _self._isWaitingForAttach = false
                _self.reloadData()
                
            } else {
                // Wait until appeared
                var token: NSObjectProtocol!
                token = NotificationCenter.default.addObserver(forName: .UIViewControllerViewDidAttach, object: viewController, queue: nil) { _ in
                    if let token = token { NotificationCenter.default.removeObserver(token) }
                    guard let _self = self else { return }
                    
                    // Reset this flag so we can assign it again later if needed
                    _self._isWaitingForAttach = false
                    _self.reloadData()
                }
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
    }
}
