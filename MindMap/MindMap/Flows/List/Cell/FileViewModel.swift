//
//  FileViewModel.swift
//  MindMap
//
//   
//

import Foundation

public struct FileViewModel {

    var title: String {
        file.title
    }
    
    var date: String {
        file.dateString
    }
    
    var file: File
    
    init(file: File) {
        self.file = file
    }
}

extension FileViewModel: ViewModelType {
    public struct Input {
    }
    
    public struct Output {
    }
    
    public func transform(input: Input) -> Output {
        
        return .init()
    }
}
