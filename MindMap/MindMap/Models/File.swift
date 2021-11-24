//
//  File.swift
//  MindMap
//
//

import Foundation

class File: Codable, Equatable {
    
    var title: String {
        rootIdea?.text ?? ""
    }
    
    var dateString: String {
        File.dateFormatter.string(from: updateDate ?? creationDate)
    }
    
    var ideas: [Idea]
    var canvasSize: Size
    var zoomLevel: Float = 1
    
    private var creationDate: Date
    private var updateDate: Date?
     
    
    init(root: Idea, canvasSize: Size = .defaultSize) {
        ideas = [root]
        creationDate = Date()
        self.canvasSize = canvasSize
    }
    
    func handleSave() {
        updateDate = Date()
    }
    
    // MARK: - Private
    
    private var rootIdea: Idea? {
        return ideas.first(where: { $0.parent == nil })
    }
    
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy HH:mm"
        return formatter
    }
    
    static func == (lhs: File, rhs: File) -> Bool {
        return lhs.creationDate == rhs.creationDate
    }
    
    static func > (lhs: File, rhs: File) -> Bool {
        guard let lhsDate = lhs.updateDate,
                let rhsDate = rhs.updateDate else {
            return false
        }
        return lhsDate > rhsDate
    }
}
