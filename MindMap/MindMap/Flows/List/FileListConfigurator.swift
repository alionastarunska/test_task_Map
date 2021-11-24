//
//  FileListConfigurator.swift
//  MindMap
//
//

import UIKit
import RxSwift
import RxRelay

class FileListConfigurator {
    
    static func configure() -> FileListViewController {
        
        let viewController = FileListViewController()
        let viewModel = FileListViewModel(fileService: DefaultFileService())
        viewController.viewModel = viewModel
        return viewController
        
    }
    
}
