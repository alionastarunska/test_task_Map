//
//  IdeaLabel.swift
//   MindMap
//
//
//

import UIKit

class IdeaLabel: UILabel, ViewModelContainer {
    
    var editTrigger: ((IdeaLabel) -> Void)?
    var deleteTrigger: ((IdeaLabel) -> Void)?
    
    var viewModel: IdeaViewModel! {
        didSet {
            bindViewModel()
        }
    }
    
    override var center: CGPoint {
        get {
            super.center
        }
        set {
            super.center = newValue
            viewModel.updateLocation(x: Float(newValue.x), y: Float(newValue.y))
        }
    }
    
    override var canBecomeFirstResponder: Bool { true }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func bindViewModel() {
        text = viewModel.idea.text
        font = viewModel.idea.isRoot ? UIFont(name: "Avenir Medium", size: 24)! : UIFont(name: "Avenir Medium", size: 20)!
        borderWidth = viewModel.idea.isRoot ? 3 : 2
        frame = .init(origin: .zero, size: intrinsicContentSize)
        center = .init(x: CGFloat(viewModel.idea.location.x), y: CGFloat(viewModel.idea.location.y))
    }
    
    // MARK: - Private
    
    private func commonInit() {
        textColor = Asset.blue.color
        font = .systemFont(ofSize: 25, weight: .medium)
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = true
        clipsToBounds = true
        layer.masksToBounds = true
        
        borderColor = textColor
        borderWidth = 2
        cornerRadius = 10
        enableMenu()
    }
    
    // MARK: - Menu
    
    private func enableMenu() {
        isUserInteractionEnabled = true
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
    }
    
    // MARK: - Padding
    
    @IBInspectable var topInset: CGFloat = 3
    @IBInspectable var bottomInset: CGFloat = 3
    @IBInspectable var leftInset: CGFloat = 12
    @IBInspectable var rightInset: CGFloat = 12
    
    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset,
                                       left: leftInset,
                                       bottom: bottomInset,
                                       right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    public override func sizeToFit() {
        super.sizeThatFits(intrinsicContentSize)
    }
    
    // MARK: - Required
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - InteractionDelegate

extension IdeaLabel: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
            
            
            let edit = UIAction(title: Localization.Buttons.edit,
                                image: UIImage(systemName: "pencil")) { [weak self] action in
                guard let self = self else { return }
                self.editTrigger?(self)
            }

            let delete = UIAction(title: Localization.Buttons.delete,
                                  image: UIImage(systemName: "trash.fill"), attributes: .destructive) { [weak self] action in
                guard let self = self else { return }
                self.deleteTrigger?(self)
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, children: [edit, delete])
            
        }
        return configuration
    }
    
}
