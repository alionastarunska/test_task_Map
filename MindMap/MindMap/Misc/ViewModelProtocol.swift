//
//  ViewModelProtocol.swift
//  MindMap
//
//   
//

import Foundation

public protocol ViewModelType {
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

public protocol ViewModelContainer {
    
    associatedtype ViewModel: ViewModelType
    
    var viewModel: ViewModel! { get set }
    
}
