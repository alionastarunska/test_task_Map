//
//  DialogViewController.swift
//  MindMap
//
//   
//

import UIKit
import Lottie
import RxSwift
import RxCocoa

class DeleteDialogViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    
    private var disposeBag: DisposeBag!
    
    var viewModel: DeleteDialogViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTexts()
        bindViewModel()
    }
    
    private func bindViewModel() {
        
        guard let viewModel = viewModel else {
            return
        }
        
        subtitleLabel.text = viewModel.subtitle
        
        let delete = deleteButton.rx.tap.asDriver().asObservable()
        let output = viewModel.transform(input: .init(deleteTrigger: delete))
        
        disposeBag = DisposeBag() {
            
            cancelButton.rx.tap
                .asDriver(onErrorDriveWith: .empty())
                .drive(with: self) { owner, _ in
                    owner.dismiss(animated: true)
                }
            
            output.closeTrigger
                .drive(with: self) { owner, _ in
                    owner.dismiss(animated: true)
                }
        }
    }
    
    private func setupTexts() {
        deleteButton.setTitle(Localization.Buttons.delete, for: [])
        titleLabel.text = Localization.Dialog.Delete.title
    }
}
