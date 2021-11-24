//
//  IdeaViewModel.swift
//  MindMap
//
//

import UIKit
import RxCocoa

class IdeaViewModel: Equatable {
    
    var idea: Idea
    
    init(idea: Idea) {
        self.idea = idea
    }
    
    static func == (lhs: IdeaViewModel, rhs: IdeaViewModel) -> Bool {
        return lhs.idea == rhs.idea
    }
    
    func updateLocation(x: Float, y: Float) {
        idea.location = Location(x: x, y: y)
    }
}

extension IdeaViewModel: ViewModelType {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        return .init()
    }
}
