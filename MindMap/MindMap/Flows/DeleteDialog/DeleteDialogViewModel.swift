//
//  DialogViewModel.swift
//  MindMap
//
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

class DeleteDialogViewModel {
    
    var subtitle: String
    var trigger: PublishRelay<Void>
    
    init(subtitle: String, trigger: PublishRelay<Void>) {
        self.subtitle = subtitle
        self.trigger = trigger
    }
    
}

extension DeleteDialogViewModel: ViewModelType {
    
    struct Input {
        let deleteTrigger: Observable<Void>
    }
    
    struct Output {
        let closeTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let closeTrigger = input.deleteTrigger
            .withUnretained(self)
            .do { owner, _ in
                owner.trigger.accept(())
            }
            .mapToVoid()
            .asDriver(onErrorJustReturn: ())

        return .init(closeTrigger: closeTrigger)
    }
}
