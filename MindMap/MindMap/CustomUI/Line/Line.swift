//
//  Line.swift
//  MindMap
//
//   
//

import UIKit

class Line: CAShapeLayer {
    
    weak var origin: IdeaLabel?
    weak var destination: IdeaLabel?
    
    init(origin: IdeaLabel, destination: IdeaLabel) {
        self.origin = origin
        self.destination = destination
        super.init()
        commonInit()
        updatePath(origin: origin.center, destination: destination.center)
    }
    
    init(origin: IdeaLabel, destination: CGPoint) {
        self.origin = origin
        super.init()
        commonInit()
        updatePath(origin: origin.center, destination: destination)
    }
    
    func updatePath(origin: CGPoint? = nil, destination: CGPoint? = nil) {
        let linePath = UIBezierPath()
        linePath.move(to: origin ?? self.origin?.center ?? .zero)
        linePath.addLine(to: destination ?? self.destination?.center ?? .zero)
        path = linePath.cgPath
    }
    
    private func commonInit() {
        strokeColor = Asset.blue.color.cgColor
        lineWidth = 2
        lineJoin = .round
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
