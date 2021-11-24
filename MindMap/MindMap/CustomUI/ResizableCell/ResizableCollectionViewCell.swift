//
//  ResizableCollectionViewCell.swift
//  MindMap
//
//   
//

import UIKit

public class ResizableCollectionViewCell: UICollectionViewCell, Reusable {
    
    private lazy var maximumWidthConstraint = widthAnchor.constraint(equalToConstant: bounds.width)
    
    var maximumWidth: CGFloat? = nil {
        didSet {
            guard let maximumWidth = maximumWidth else {
                maximumWidthConstraint.isActive = false
                return
            }
            maximumWidthConstraint.isActive = true
            maximumWidthConstraint.constant = maximumWidth
        }
    }
    
}
