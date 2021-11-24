//
//  MapConfigurator.swift
//  MindMap
//
//   
//

import Foundation

class MapConfigurator {
    
    static func configure(fileViewModel: FileViewModel, fileService: FileService) -> MapViewController {
        
        let viewController = MapViewController()
        let viewModel = MapViewModel(fileService: fileService, file: fileViewModel)
        viewController.viewModel = viewModel
        return viewController
        
    }
    
}
