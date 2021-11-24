//
//  DialogConfigurator.swift
//  MindMap
//
//   
//

import UIKit
import RxSwift
import RxRelay

class DeleteDialogConfigurator {
    
    static func configure(subtitle: String, trigger: PublishRelay<Void>) -> DeleteDialogViewController {
        
        let viewController = DeleteDialogViewController()
        let viewModel = DeleteDialogViewModel(subtitle: subtitle, trigger: trigger)
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .overFullScreen
        return viewController
        
    }
    
}
