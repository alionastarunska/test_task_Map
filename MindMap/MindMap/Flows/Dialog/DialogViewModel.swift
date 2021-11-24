//
//  DialogViewModel.swift
//  MindMap
//
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

class DialogViewModel {
    
    var text: String = ""
    var title: String
    var subtitle: String
    var trigger: PublishRelay<String>
    
    private let disposeBag = DisposeBag()
    
    init(text: String, title: String, subtitle: String, trigger: PublishRelay<String>) {
        self.text = text
        self.title = title
        self.subtitle = subtitle
        self.trigger = trigger
    }
    
}

extension DialogViewModel: ViewModelType {
    
    struct Input {
        let saveTrigger: Observable<Void>
        let text: Observable<String>
    }
    
    struct Output {
        let saveEnabledDriver: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let saveEnabledDriver = input.text.map { text in
                return !text.isEmpty
            }
            .asDriver(onErrorJustReturn: false)
        
        input.saveTrigger.flatMapLatest {
            input.text
        }
        .bind(to: trigger)
        .disposed(by: disposeBag)

        return .init(saveEnabledDriver: saveEnabledDriver)
    }
}
