//
//  DialogConfigurator.swift
//  MindMap
//
//   
//

import UIKit
import RxSwift
import RxRelay

class DialogConfigurator {
    
    static func configure(text: String, title: String, subtitle: String, trigger: PublishRelay<String>) -> DialogViewController {
        
        let viewController = DialogViewController()
        let viewModel = DialogViewModel(text: text, title: title, subtitle: subtitle, trigger: trigger)
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .overFullScreen
        return viewController
        
    }
    
}
