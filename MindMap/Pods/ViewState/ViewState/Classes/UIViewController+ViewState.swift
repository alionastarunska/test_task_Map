//
//  UIViewController+ViewState.swift
//  APExtensions
//
//  Created by Anton Plebanovich on 5/19/17.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


#if DEBUG
    private let c_debugViewState = false
#else
    private let c_debugViewState = false
#endif

// ******************************* MARK: - Swizzle Functions

private func swizzleClassMethods(class: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    guard class_isMetaClass(`class`) else { return }
    
    let originalMethod = class_getClassMethod(`class`, originalSelector)!
    let swizzledMethod = class_getClassMethod(`class`, swizzledSelector)!
    
    swizzleMethods(class: `class`, originalSelector: originalSelector, originalMethod: originalMethod, swizzledSelector: swizzledSelector, swizzledMethod: swizzledMethod)
}

private func swizzleMethods(class: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    guard !class_isMetaClass(`class`) else { return }
    
    let originalMethod = class_getInstanceMethod(`class`, originalSelector)!
    let swizzledMethod = class_getInstanceMethod(`class`, swizzledSelector)!
    
    swizzleMethods(class: `class`, originalSelector: originalSelector, originalMethod: originalMethod, swizzledSelector: swizzledSelector, swizzledMethod: swizzledMethod)
}

private func swizzleMethods(class: AnyClass, originalSelector: Selector, originalMethod: Method, swizzledSelector: Selector, swizzledMethod: Method) {
    let didAddMethod = class_addMethod(`class`, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    
    if didAddMethod {
        class_replaceMethod(`class`, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

// ******************************* MARK: - Load

public final class ViewState {
    public static func setupOnce() {
        _ = UIViewController.setupOnce
    }
}

private extension UIViewController {
    @objc static let setupOnce: Int = {
        swizzleMethods(class: UIViewController.self, originalSelector: #selector(willMove(toParent:)), swizzledSelector: #selector(swizzled_willMove(toParent:)))
        swizzleMethods(class: UIViewController.self, originalSelector: #selector(viewDidLoad), swizzledSelector: #selector(swizzled_viewDidLoad))
        swizzleMethods(class: UIViewController.self, originalSelector: #selector(viewWillAppear(_:)), swizzledSelector: #selector(swizzled_viewWillAppear(_:)))
        swizzleMethods(class: UIViewController.self, originalSelector: #selector(becomeFirstResponder), swizzledSelector: #selector(swizzled_becomeFirstResponder))
        swizzleMethods(class: UIViewController.self, originalSelector: #selector(viewDidAppear(_:)), swizzledSelector: #selector(swizzled_viewDidAppear(_:)))
        swizzleMethods(class: UIViewController.self, originalSelector: #selector(viewWillDisappear(_:)), swizzledSelector: #selector(swizzled_viewWillDisappear(_:)))
        swizzleMethods(class: UIViewController.self, originalSelector: #selector(viewDidDisappear(_:)), swizzledSelector: #selector(swizzled_viewDidDisappear(_:)))
        
        return 0
    }()
}

// ******************************* MARK: - ViewState and Notifications

private var associatedStateKey = 0


public extension Notification.Name {
    /// UIViewController willMove(toParentViewController:) method was called notification.
    /// You may check `object` notification's property for UIViewController object and `userInfo["parent"]` parameter if needed.
    static let UIViewControllerWillMoveToParentViewController = Notification.Name("UIViewControllerWillMoveToParentViewController")
    
    /// UIViewController viewDidLoad() method was called notification.
    /// You may check `object` notification's property for UIViewController object and `userInfo["viewState"]` parameters if needed.
    static let UIViewControllerViewDidLoad = Notification.Name("UIViewControllerViewDidLoad")
    
    /// UIViewController viewWillAppear(_:) method was called notification.
    /// You may check `object` notification's property for UIViewController object and `userInfo["animated"]` or `userInfo["viewState"]` parameters if needed.
    static let UIViewControllerViewWillAppear = Notification.Name("UIViewControllerViewWillAppear")
    
    /// UIViewController becomeFirstResponder() method was called notification.
    /// Called between willAppear and didAppear when controller is attached to responders chain.
    /// You may check `object` notification's property for UIViewController object and `userInfo["viewState"]` parameters if needed.
    static let UIViewControllerViewDidAttach = Notification.Name("UIViewControllerViewDidAttach")
    
    /// UIViewController viewDidAppear(_:) method was called notification.
    /// You may check `object` notification's property for UIViewController object and `userInfo["animated"]` or `userInfo["viewState"]` parameters if needed.
    static let UIViewControllerViewDidAppear = Notification.Name("UIViewControllerViewDidAppear")
    
    /// UIViewController viewWillDisappear(_:) method was called notification.
    /// You may check `object` notification's property for UIViewController object and `userInfo["animated"]` or `userInfo["viewState"]` parameters if needed.
    static let UIViewControllerViewWillDisappear = Notification.Name("UIViewControllerViewWillDisappear")
    
    /// UIViewController viewDidDisappear(_:) method was called notification.
    /// You may check `object` notification's property for UIViewController object and `userInfo["animated"]` or `userInfo["viewState"]` parameters if needed.
    static let UIViewControllerViewDidDisappear = Notification.Name("UIViewControllerViewDidDisappear")
    
    /// UIViewController viewState did changed notification.
    /// You may check `object` notification's property for UIViewController object.
    /// `userInfo` dictionary contains `viewState` param and may contain `animated` and `parent` parameters depending on case.
    static let UIViewControllerViewStateDidChange = Notification.Name("UIViewControllerViewStateDidChange")
}

// ******************************* MARK: - ViewControllerExtendedStates

/// You can conform to that protocol in your view controller to get .viewDidAttach() and .viewStateDidChange() calls
public protocol ViewControllerExtendedStates {
    func viewDidAttach()
    func viewStateDidChange()
}

public extension ViewControllerExtendedStates {
    func viewDidAttach() {}
    func viewStateDidChange() {}
}

// ******************************* MARK: - UIViewController Swizzling

extension UIViewController {
    /// View controller view's state enum
    public enum ViewState: Int {
        case notLoaded = 0
        case didLoad = 1
        case willAppear = 2
        case didAttach = 3
        case didAppear = 4
        case willDisappear = 5
        case didDisappear = 6
        
        /// Return whether state is one of passed ones.
        func isOneOf(states: [ViewState]) -> Bool {
            return states.contains(self)
        }
    }
    
    /// View controller view's state
    open var viewState: ViewState {
        get {
            if let state = objc_getAssociatedObject(self, &associatedStateKey) as? ViewState {
                return state
            } else {
                objc_setAssociatedObject(self, &associatedStateKey, ViewState.notLoaded, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return ViewState.notLoaded
            }
        }
        set {
            objc_setAssociatedObject(self, &associatedStateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if c_debugViewState { logViewState() }
        }
    }
    
    @objc private func swizzled_willMove(toParent parent: UIViewController?) {
        var userInfo: [String: Any] = [:]
        userInfo["viewState"] = viewState
        userInfo["parent"] = parent
        NotificationCenter.default.post(name: .UIViewControllerWillMoveToParentViewController, object: self, userInfo: userInfo)
        NotificationCenter.default.post(name: .UIViewControllerViewStateDidChange, object: self, userInfo: userInfo)
        (self as? ViewControllerExtendedStates)?.viewStateDidChange()
        
        swizzled_willMove(toParent: parent)
    }
    
    @objc private func swizzled_viewDidLoad() {
        viewState = .didLoad
        let userInfo: [String: Any] = ["viewState": viewState]
        NotificationCenter.default.post(name: .UIViewControllerViewDidLoad, object: self, userInfo: userInfo)
        NotificationCenter.default.post(name: .UIViewControllerViewStateDidChange, object: self, userInfo: userInfo)
        (self as? ViewControllerExtendedStates)?.viewStateDidChange()
        
        swizzled_viewDidLoad()
    }
    
    @objc private func swizzled_viewWillAppear(_ animated: Bool) {
        viewState = .willAppear
        let userInfo: [String: Any] = ["viewState": viewState, "animated": animated]
        NotificationCenter.default.post(name: .UIViewControllerViewWillAppear, object: self, userInfo: userInfo)
        NotificationCenter.default.post(name: .UIViewControllerViewStateDidChange, object: self, userInfo: userInfo)
        (self as? ViewControllerExtendedStates)?.viewStateDidChange()
        
        swizzled_viewWillAppear(animated)
    }
    
    @objc private func swizzled_becomeFirstResponder() -> Bool {
        if viewState == .willAppear {
            viewState = .didAttach
            let userInfo: [String: Any] = ["viewState": viewState]
            NotificationCenter.default.post(name: .UIViewControllerViewDidAttach, object: self, userInfo: userInfo)
            (self as? ViewControllerExtendedStates)?.viewDidAttach()
            NotificationCenter.default.post(name: .UIViewControllerViewStateDidChange, object: self, userInfo: userInfo)
            (self as? ViewControllerExtendedStates)?.viewStateDidChange()
        } else {
            if c_debugViewState { self.log("becomeFirstResponder") }
        }
        
        return swizzled_becomeFirstResponder()
    }
    
    @objc private func swizzled_viewDidAppear(_ animated: Bool) {
        viewState = .didAppear
        let userInfo: [String: Any] = ["viewState": viewState, "animated": animated]
        NotificationCenter.default.post(name: .UIViewControllerViewDidAppear, object: self, userInfo: userInfo)
        NotificationCenter.default.post(name: .UIViewControllerViewStateDidChange, object: self, userInfo: userInfo)
        (self as? ViewControllerExtendedStates)?.viewStateDidChange()
        
        swizzled_viewDidAppear(animated)
    }
    
    @objc private func swizzled_viewWillDisappear(_ animated: Bool) {
        viewState = .willDisappear
        let userInfo: [String: Any] = ["viewState": viewState, "animated": animated]
        NotificationCenter.default.post(name: .UIViewControllerViewWillDisappear, object: self, userInfo: userInfo)
        NotificationCenter.default.post(name: .UIViewControllerViewStateDidChange, object: self, userInfo: userInfo)
        (self as? ViewControllerExtendedStates)?.viewStateDidChange()
        
        swizzled_viewWillDisappear(animated)
    }
    
    @objc private func swizzled_viewDidDisappear(_ animated: Bool) {
        viewState = .didDisappear
        let userInfo: [String: Any] = ["viewState": viewState, "animated": animated]
        NotificationCenter.default.post(name: .UIViewControllerViewDidDisappear, object: self, userInfo: userInfo)
        NotificationCenter.default.post(name: .UIViewControllerViewStateDidChange, object: self, userInfo: userInfo)
        (self as? ViewControllerExtendedStates)?.viewStateDidChange()
        
        swizzled_viewDidDisappear(animated)
    }
}

// ******************************* MARK: - Keyboard

private var c_hideKeyboardGestureRecognizerAssociationKey = 0
private var c_hideKeyboardGestureRecognizerDelegateAssociationKey = 0

private class HideKeyboardGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Do not dismiss on contol element clicks. Like button, switch or segment.
        return !(touch.view is UIControl)
    }
}

public extension UIViewController {
    private var hideKeyboardGestureRecognizer: UITapGestureRecognizer? {
        get {
            return objc_getAssociatedObject(self, &c_hideKeyboardGestureRecognizerAssociationKey) as? UITapGestureRecognizer
        }
        set {
            objc_setAssociatedObject(self, &c_hideKeyboardGestureRecognizerAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var hideKeyboardGestureRecognizerDelegate: UIGestureRecognizerDelegate? {
        get {
            return objc_getAssociatedObject(self, &c_hideKeyboardGestureRecognizerDelegateAssociationKey) as? UIGestureRecognizerDelegate
        }
        set {
            objc_setAssociatedObject(self, &c_hideKeyboardGestureRecognizerDelegateAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc private func _endEditing(_ sender: Any) {
        view.endEditing(true)
    }
    
    /// Allows to hide keyboard when touch outside
    @IBInspectable var hideKeyboardOnTouch: Bool {
        get {
            return hideKeyboardGestureRecognizer != nil
        }
        set {
            if newValue {
                if hideKeyboardGestureRecognizer == nil {
                    let hideKeyboardGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController._endEditing))
                    hideKeyboardGestureRecognizerDelegate = HideKeyboardGestureRecognizerDelegate()
                    hideKeyboardGestureRecognizer.delegate = hideKeyboardGestureRecognizerDelegate
                    hideKeyboardGestureRecognizer.cancelsTouchesInView = false
                    self.hideKeyboardGestureRecognizer = hideKeyboardGestureRecognizer
                    
                    if isViewLoaded {
                        view.addGestureRecognizer(hideKeyboardGestureRecognizer)
                    } else {
                        var notificationToken: NSObjectProtocol!
                        
                        // TODO: There is a possible memory leak if view is never loaded and VC is dealocated. Better solution would be to have closures executed at a specific time and dealocated together with VC.
                        notificationToken = NotificationCenter.default.addObserver(forName: .UIViewControllerViewDidLoad, object: nil, queue: nil, using: { [weak self] n in
                            if let notificationToken = notificationToken { NotificationCenter.default.removeObserver(notificationToken) }
                            
                            if let hideRecognizer = self?.hideKeyboardGestureRecognizer {
                                self?.view.addGestureRecognizer(hideRecognizer)
                            }
                        })
                    }
                }
            } else {
                if let hideRecognizer = hideKeyboardGestureRecognizer {
                    view.removeGestureRecognizer(hideRecognizer)
                    self.hideKeyboardGestureRecognizer = nil
                    self.hideKeyboardGestureRecognizerDelegate = nil
                }
            }
        }
    }
    
    // ******************************* MARK: - Private Methods
    
    private func logViewState() {
        log("\(viewState)")
    }
    
    private func log(_ string: String) {
        let pointer = Unmanaged<AnyObject>.passUnretained(self).toOpaque().debugDescription
        let className = "\(type(of: self))"
        print("\(pointer) - \(className) - \(string)")
    }
}
