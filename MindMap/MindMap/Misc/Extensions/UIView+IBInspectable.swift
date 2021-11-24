//
//  UIView.swift
//  MindMap
//
//

import UIKit

extension UIView {
    
    // MARK: - IBInspectable
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return layer.borderColor?.uiColor
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }

    public func popIn(duration: Float = 0.3, delay: Float = 0) {
        self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(
            withDuration: TimeInterval(duration), delay: TimeInterval(delay), usingSpringWithDamping: 0.55, initialSpringVelocity: 3,
            options: .curveEaseOut, animations: {
                self.transform = .identity
                self.alpha = 1
            }, completion: nil)
    }
    
    public func popOut(duration: Float = 0.3, delay: Float = 0, completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: TimeInterval(0.2), delay: TimeInterval(0), usingSpringWithDamping: 0.55, initialSpringVelocity: 3,
            options: .curveEaseOut, animations: {
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: { ( _ ) in
                UIView.animate(
                    withDuration: TimeInterval(duration), delay: TimeInterval(delay), usingSpringWithDamping: 0.55, initialSpringVelocity: 3,
                    options: .curveEaseOut, animations: {
                        self.alpha = 0
                        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    }) { _ in
                        completion()
                    }
            })
    }
    
}

private extension CGColor {
    
    var uiColor: UIKit.UIColor {
        return UIKit.UIColor(cgColor: self)
    }
    
}

extension UIView {

    func add(to container: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(self)
        topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
    }
    
}
