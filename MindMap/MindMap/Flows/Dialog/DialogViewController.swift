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

class DialogViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var ideaTextField: UITextField!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var animationView: AnimationView!
    
    private var disposeBag: DisposeBag!
    
    var viewModel: DialogViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTexts()
        startAnimation()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ideaTextField.becomeFirstResponder()
    }
    
    private func bindViewModel() {
        
        guard let viewModel = viewModel else {
            return
        }
        
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        ideaTextField.text = viewModel.text
        
        let saveTrigger = saveButton.rx.tap.asDriver().asObservable()
        let text = ideaTextField.rx.text.asDriver().asObservable().compactMap { $0 ?? "" }
        
        let output = viewModel.transform(input: .init(saveTrigger: saveTrigger, text: text))
        
        disposeBag = DisposeBag() {
            
            cancelButton.rx.tap
                .asDriver(onErrorDriveWith: .empty())
                .drive(with: self) { owner, _ in
                    owner.dismiss(animated: true)
                }
            
            output.saveEnabledDriver.drive(with: saveButton) { owner, enabled in
                owner.isEnabled = enabled
                owner.alpha = enabled ? 1 : 0.5
            }

        }
    }
    
    private func setupTexts() {
        saveButton.setTitle(Localization.Buttons.save, for: [])
        ideaTextField.placeholder = Localization.Dialog.placeholder
    }
}

private extension DialogViewController {
    
    func startAnimation() {
        
        animationView.animationSpeed = 1
        animationView.contentMode = .scaleToFill
        animationView.loopMode = .loop
        animationView.play()
        
    }
    
}
