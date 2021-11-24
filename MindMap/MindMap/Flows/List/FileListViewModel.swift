//
//  FileListViewModel.swift
//  MindMap
//
//   
//

import Foundation
import RxSwift
import RxCocoa

class FileListViewModel {
    
    let fileService: FileService
    private let disposeBag = DisposeBag()
    
    private let filesRelay: PublishRelay<[File]> = .init()
    
    init(fileService: FileService) {
        self.fileService = fileService
    }
}

extension FileListViewModel: ViewModelType {
    
    struct Input {
        let viewDidLoadTrigger: Observable<Void>
        let addTrigger: Observable<String>
        let modelSelected: Observable<FileViewModel>
    }
    
    struct Output {
        let sectionDriver: Driver<[FileSection]>
        let addDriver: Driver<FileViewModel>
        let navigationTrigger: Driver<FileViewModel>
    }
    
    func transform(input: Input) -> Output {
        
        fileService.fetchFiles().bind(to: filesRelay).disposed(by: disposeBag)
        
        let sections = Observable.combineLatest(
            input.viewDidLoadTrigger,
            filesRelay.asObservable()
        )
            .map { _, files in
                return [FileSection(items: files.map { FileViewModel(file: $0) })]
            }
            .asDriver(onErrorJustReturn: [])
        
        let fileObservable = input
            .addTrigger
            .withUnretained(self)
            .map { (owner, name) -> File in
                let newName = owner.fileService.availableFileName(for: name)
                let file = File(root: Idea(text: newName))
                return file
            }
        
        let addDriver = fileObservable
            .map { file -> FileViewModel in
                return FileViewModel(file: file)
            }
            .asDriver(onErrorJustReturn: .init(file: .init(root: .init(text: ""))))
        
        addDriver
            .asObservable()
            .withUnretained(self)
            .subscribe { owner, file in
                owner.fileService.save(file.file)
            }
            .disposed(by: disposeBag)
        
        let navigationTrigger = input.modelSelected.asDriver(onErrorJustReturn: .init(file: .init(root: .init(text: ""))))
        
        return .init(sectionDriver: sections, addDriver: addDriver, navigationTrigger: navigationTrigger)
    }
}
