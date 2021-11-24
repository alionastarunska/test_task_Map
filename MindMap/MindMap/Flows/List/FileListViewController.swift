//
//  FileListViewController.swift
//  MindMap
//
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class FileListViewController: UIViewController {
    
    private var collectionView: IdeasListCollectionView!
    private var disposeBag: DisposeBag!
    private var addTrigger: PublishRelay<String> = .init()
    private var viewDidLoadTrigger: PublishRelay<Void> = .init()
    
    var viewModel: FileListViewModel!
    
    private var dataSource = RxCollectionViewSectionedReloadDataSource<FileSection>(
        configureCell: { (datasource, collectionView, indexPath, item) -> UICollectionViewCell in
            return collectionView.dequeueResizableCell(for: indexPath, with: item) as FileCell
        })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupUI()
        setupCollectionView()
        bindViewModel()
        
        viewDidLoadTrigger.accept(())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidLoadTrigger.accept(())
    }
}

private extension FileListViewController {
    
    func setupNavigationBar() {
        title = Localization.MainScreen.title
        navigationItem.rightBarButtonItem = .init(image: .add, style: .done, target: self, action: #selector(addAction) )
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "Avenir Medium", size: 24)!,
             NSAttributedString.Key.foregroundColor: Asset.blue.color]
    }
    
    func setupUI() {
        view.backgroundColor = .white
    }
    
    func setupCollectionView() {
        collectionView = IdeasListCollectionView(frame: view.bounds)
        collectionView.contentInset = .init(top: 30, left: 0, bottom: 30, right: 0)
        collectionView.register(FileCell.self, forCellWithReuseIdentifier: FileCell.reuseIdentifier())
        collectionView.add(to: view)
    }
    
    @objc func addAction() {
        
        let dialogViewController = DialogConfigurator.configure(text: "",
                                                                title: Localization.Dialog.title,
                                                                subtitle: Localization.Dialog.subtitle,
                                                                trigger: addTrigger)
        navigationController?.present(dialogViewController, animated: true, completion: nil)
        
    }
    
    func bindViewModel() {
        
        guard let viewModel = viewModel else {
            return
        }
        
        let modelSelected = collectionView.rx
            .modelSelected(FileViewModel.self)
            .asDriver()
            .asObservable()
        
        let output = viewModel.transform(input: .init(viewDidLoadTrigger: viewDidLoadTrigger.asObservable(),
                                                      addTrigger: addTrigger.asObservable(),
                                                      modelSelected: modelSelected))
                                         
        disposeBag = DisposeBag {

            output.sectionDriver.drive(collectionView.rx.items(dataSource: dataSource))

            output.navigationTrigger.drive(with: self) { owner, model in
                owner.navigateToMap(with: model)
                UIFeedbackGenerator.selectionChanged()
            }
            
            output.addDriver.drive(with: self) { owner, model in
                owner.navigateToMap(with: model)
            }
        }
    }
    
    func navigateToMap(with model: FileViewModel) {
        if let presentedView = navigationController?.presentedViewController {
            presentedView.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                let vc = MapConfigurator.configure(fileViewModel: model, fileService: self.viewModel.fileService)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = MapConfigurator.configure(fileViewModel: model, fileService: viewModel.fileService)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Private types

fileprivate final class IdeasListCollectionView: UICollectionView {
    
    init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: frame.width - 60, height: 60)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 30
        
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = .white
        showsHorizontalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
