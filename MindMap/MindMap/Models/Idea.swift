//
//  Idea.swift
//  MindMap
//
//

import UIKit

class Idea: Codable, Equatable {
    
    var parent: Idea?
    var text: String
    var location: Location
    
    var isRoot: Bool {
        return parent == nil
    }
    
    init(parent: Idea? = nil,
         text: String,
         location: Location = Size.defaultSize.center) {
        self.parent = parent
        self.text = text
        self.location = location
    }
    
    static func == (lhs: Idea, rhs: Idea) -> Bool {
        return lhs.parent == rhs.parent &&
        lhs.text == rhs.text
    }
    
}
