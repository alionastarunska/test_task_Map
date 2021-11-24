//
//  Reusable.swift
//  MindMap
//
//

import UIKit

public protocol Reusable {
    
    static func reuseIdentifier() -> String
    
}

public extension Reusable where Self: UIView {
    
    static func reuseIdentifier() -> String {
        String(describing: Self.self)
    }
    
}
