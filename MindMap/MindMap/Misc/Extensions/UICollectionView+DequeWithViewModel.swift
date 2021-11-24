//
//  UICollectionView+DequeWithViewModel.swift
//  MindMap
//
//   
//

import UIKit

extension UICollectionView {
    
    func dequeueResizableCell<Cell>(for indexPath: IndexPath, with viewModel: Cell.ViewModel) -> Cell
    where Cell: ResizableCollectionViewCell & ViewModelContainer {
        let cell = dequeueReusableCell(for: indexPath, with: viewModel) as Cell
        cell.maximumWidth = maximumWidth
        return cell
    }
    
    var maximumWidth: CGFloat {
        guard let collectionViewFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return bounds.width
        }
        let sectionInset = collectionViewFlowLayout.sectionInset
        let minimumInteritemSpacing = collectionViewFlowLayout.minimumInteritemSpacing
        return bounds.width - (sectionInset.left + sectionInset.right + minimumInteritemSpacing).rounded(.up)
    }
    
    func dequeueReusableCell<Cell>(for indexPath: IndexPath, with viewModel: Cell.ViewModel) -> Cell
    where Cell: UICollectionViewCell & Reusable & ViewModelContainer {
        var cell = dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier(), for: indexPath) as! Cell
        cell.viewModel = viewModel
        return cell
    }
}
