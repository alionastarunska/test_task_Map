//
//  File.swift
//  MindMap
//
//

import UIKit

struct Location: Codable, Equatable {
    var x: Float
    var y: Float
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.x == rhs.x &&
        lhs.y == rhs.y
    }
}

struct Size: Codable, Equatable {
    var height: Float
    var width: Float
    
    static func == (lhs: Size, rhs: Size) -> Bool {
        return lhs.height == rhs.height &&
        lhs.width == rhs.width
    }
    
    var center: Location {
        .init(x: width / 2, y: height / 2)
    }
    
    static var defaultSize: Size {
        let screenSize = UIScreen.main.bounds.size
        return Size(height: Float(screenSize.width * 1.5),
                    width: Float(screenSize.height * 1.5))
    }
}
