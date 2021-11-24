//
//  MapViewModel.swift
//  MindMap
//
//   
//

import UIKit
import RxCocoa
import RxSwift

class MapViewModel {
    
    var canvasSize: CGSize {
        get {
            let size = fileViewModel.file.canvasSize
            return .init(width: CGFloat(size.width), height: CGFloat(size.height))
        }
        set {
            fileViewModel.file.canvasSize = .init(height: Float(newValue.width), width: Float(newValue.height))
        }
    }
    
    var zoomLevel: CGFloat {
        get {
            CGFloat(fileViewModel.file.zoomLevel)
        }
        set {
            fileViewModel.file.zoomLevel = Float(newValue)
        }
    }
    
    private let fileService: FileService
    private let fileViewModel: FileViewModel
    
    private let disposeBag = DisposeBag()
    
    private var updateRelay: PublishRelay<Void> = .init()
    private var closeRelay: PublishRelay<Void> = .init()
    
    init(fileService: FileService, file: FileViewModel) {
        self.fileService = fileService
        self.fileViewModel = file
    }
    
    func addIdea(parent: IdeaViewModel, with name: String, location: Location) {
        let newName = uniqueName(name: name)
        let idea = Idea(parent: parent.idea, text: newName, location: location)
        fileViewModel.file.ideas.append(idea)
        
        updateRelay.accept(())
    }
    
    private func uniqueName(for idea: IdeaViewModel? = nil, name: String) -> String {
        let names = fileViewModel.file.ideas.map { $0.text }.filter({ $0 != idea?.idea.text })
        var newName = name
        if names.contains(name) {
            var copyIndex = 0
            while names.contains(newName) {
                copyIndex += 1
                newName = name + " (\(copyIndex))"
            }
        }
        return newName
    }
    
    private func delete(idea: Idea) {
        let children = fileViewModel.file.ideas.filter { $0.parent == idea }
        children.forEach {
            delete(idea: $0)
        }
        guard let index = fileViewModel.file.ideas.firstIndex(of: idea) else { return }
        fileViewModel.file.ideas.remove(at: index)
        updateRelay.accept(())
    }
}

extension MapViewModel: ViewModelType {
    
    struct Input {
        let saveFileTrigger: Observable<Void>
        let viewDidAppearTrigger: Observable<Void>
        let updateTrigger: Observable<(IdeaViewModel, String)>
        let deleteTrigger: Observable<(IdeaViewModel)>
    }
    
    struct Output {
        let mapDriver: Driver<[IdeaViewModel]>
        let titleDriver: Driver<String>
        let closeDriver: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        input.saveFileTrigger
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.fileService.save(owner.fileViewModel.file)
            }
            .disposed(by: disposeBag)
        
        input.viewDidAppearTrigger
            .bind(to: updateRelay)
            .disposed(by: disposeBag)
        
        input.updateTrigger
            .withUnretained(self)
            .subscribe { owner, update in
                let isRoot = update.0.idea.isRoot
                let name = owner.uniqueName(for: update.0, name: update.1)
                if isRoot { owner.fileService.delete(owner.fileViewModel.file) }
                update.0.idea.text = name
                if isRoot { owner.fileService.save(owner.fileViewModel.file) }
                owner.updateRelay.accept(())
            }
            .disposed(by: disposeBag)
        
        input.deleteTrigger
            .withUnretained(self)
            .subscribe { owner, ideaViewModel in
                if ideaViewModel.idea.isRoot {
                    owner.fileService.delete(owner.fileViewModel.file)
                    owner.closeRelay.accept(())
                } else {
                    owner.delete(idea: ideaViewModel.idea)
                }
            }
            .disposed(by: disposeBag)
        
        let mapDriver = updateRelay
            .withUnretained(self)
            .map { owner, _ in
                owner.fileViewModel.file.ideas.map { IdeaViewModel(idea: $0) }
            }
            .asDriver(onErrorJustReturn: [])
        
        let titleDriver = updateRelay.withUnretained(self).flatMap { owner, _ in
            Observable<String>.just(owner.fileViewModel.title)
        }.asDriver(onErrorJustReturn: "")
        
        let closeDriver = closeRelay.asDriver(onErrorJustReturn: ())
        
        return .init(mapDriver: mapDriver, titleDriver: titleDriver, closeDriver: closeDriver)
    }
}
