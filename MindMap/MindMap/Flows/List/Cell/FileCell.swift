//
//  IdeasCell.swift
//  MindMap
//
//

import UIKit
import RxSwift
import RxCocoa

class FileCell: ResizableCollectionViewCell, ViewModelContainer {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "Avenir", size: 24)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "Avenir", size: 14)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let openImageView: UIImageView = {
        let image = UIImage(systemName: "arrow.right")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let firstStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        return stackView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        return stackView
    }()
    
    var viewModel: FileViewModel! {
        didSet {
            bindViewModel()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else {
            return
        }
        
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.date
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        
        firstStackView.addArrangedSubview(subtitleLabel)
        firstStackView.addArrangedSubview(openImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(firstStackView)
        
        contentView.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
        
        shadowColor = .black
        shadowOffset = .init(width: 2, height: 2)
        shadowOpacity = 0.2
        shadowRadius = 5
        
        layoutIfNeeded()
    }
}
