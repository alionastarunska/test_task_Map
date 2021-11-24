//
//  FileSection.swift
//  MindMap
//
//

//

import RxDataSources

struct FileSection {
    
    var items: [FileViewModel]

}

extension FileSection: SectionModelType {
    
    init(original: FileSection, items: [FileViewModel]) {
        self = original
        self.items = items
    }
    
}
