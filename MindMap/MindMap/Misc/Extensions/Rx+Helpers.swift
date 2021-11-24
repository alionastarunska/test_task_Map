//
//  Rx+Helpers.swift
//  MindMap
//
//   
//

import Foundation
import RxSwift
import RxCocoa

extension Observable {
    func mapToVoid() -> Observable<Void> {
        return self.map { _ in }
    }
}
