//
//  MapViewController.swift
//

import UIKit
import RxSwift
import RxCocoa

class MapViewController: UIViewController, ViewModelContainer {
    
    var viewModel: MapViewModel!
    
    private var saveFileTrigger: PublishRelay<Void> = .init()
    private var viewDidAppearTrigger: PublishRelay<Void> = .init()
    private var newIdeaRelay: PublishRelay<String> = .init()
    private var editIdeaRelay: PublishRelay<String> = .init()
    private var deleteIdeaRelay: PublishRelay<Void> = .init()
    private var updateRelay: PublishRelay<(IdeaViewModel, String)> = .init()
    private var deleteRelay: PublishRelay<(IdeaViewModel)> = .init()
    
    private var disposeBag: DisposeBag!
    
    // MARK: - UI
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.backgroundColor = .clear
        scrollView.delaysContentTouches = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.bouncesZoom = false
        return scrollView
    }()
    
    private var canvasView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // MARK: - Temp
    
    private weak var currentIdeaLabel: IdeaLabel?
    private weak var currentLine: Line?
    private var currentPoint: CGPoint?
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    
    private var labels: [IdeaLabel] {
        canvasView.subviews.compactMap { $0 as? IdeaLabel }
    }
    
    private var lines: [Line] {
        canvasView.layer.sublayers?.compactMap({ $0 as? Line }) ?? []
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearTrigger.accept(())
        center()
    }
    
    // MARK: - Private
    
    private func insertLabel(for viewModel: IdeaViewModel) {
        let label = IdeaLabel(frame: .zero)
        canvasView.addSubview(label)
        label.viewModel = viewModel
        label.popIn()
        
        label.editTrigger = { [weak self] label in
            self?.edit(label: label)
        }
        
        label.deleteTrigger = { [weak self] label in
            guard let self = self else { return }
            self.currentIdeaLabel = label
            let subtitle = label.viewModel.idea.isRoot ? Localization.Dialog.Delete.fileSubtitle : Localization.Dialog.Delete.childrenSubtitle
            let vc = DeleteDialogConfigurator.configure(subtitle: subtitle, trigger: self.deleteIdeaRelay)
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    private func edit(label: IdeaLabel) {
        currentIdeaLabel = label
        let vc = DialogConfigurator.configure(text: label.text ?? "", title: Localization.Dialog.title, subtitle: "", trigger: editIdeaRelay)
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        scrollView.delegate = self
        scrollView.contentSize = view.frame.size
        scrollView.maximumZoomScale = 3
        scrollView.minimumZoomScale = 0.5
        scrollView.layer.borderWidth = 1
        scrollView.layer.borderColor = UIColor.black.cgColor
        scrollView.add(to: view)
        canvasView.layer.borderWidth = 1
        canvasView.layer.borderColor = UIColor.green.cgColor
        canvasView.add(to: scrollView)
        
        widthConstraint = canvasView.widthAnchor.constraint(equalToConstant: view.frame.width * 1.5)
        heightConstraint = canvasView.heightAnchor.constraint(equalToConstant: view.frame.height * 1.5)

        widthConstraint?.isActive = true
        heightConstraint?.isActive = true

        let addGesture = UIPanGestureRecognizer(target: self, action: #selector(addGestureAction(_:)))
        addGesture.delegate = self
        addGesture.maximumNumberOfTouches = 1
        canvasView.addGestureRecognizer(addGesture)
        
        let moveGesture = UIPanGestureRecognizer(target: self, action: #selector(moveGestureAction(_:)))
        moveGesture.minimumNumberOfTouches = 2
        moveGesture.maximumNumberOfTouches = 2
        canvasView.addGestureRecognizer(moveGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapGesture(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        canvasView.addGestureRecognizer(doubleTapGesture)
        
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"),
                                         style: .done,
                                         target: self,
                                         action: #selector(closeAction))
        
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func center() {
        scrollView.contentOffset = .init(x: (canvasView.frame.width - view.frame.width) / 2,
                                         y: (canvasView.frame.height - view.frame.height) / 2)
    }
    
    @objc private func closeAction() {
        saveFileTrigger.accept(())
        navigationController?.popViewController(animated: true)
    }
    
    private func label(at point: CGPoint) -> IdeaLabel? {
        canvasView.subviews.first(where: { $0.frame.contains(point) }) as? IdeaLabel
    }
    
    private func label(for viewModel: IdeaViewModel) -> IdeaLabel? {
        canvasView.subviews.compactMap({ $0 as? IdeaLabel }).first(where: { $0.viewModel == viewModel })
    }
    
    private func createIdea(at point: CGPoint) {
        guard currentIdeaLabel != nil else {
            return
        }
        
        let vc = DialogConfigurator.configure(text: "", title: Localization.Dialog.title, subtitle: "", trigger: newIdeaRelay)
        navigationController?.present(vc, animated: true)
        currentLine?.removeFromSuperlayer()
        UIFeedbackGenerator.success()
    }
    
    private func idle() {
        currentLine?.removeFromSuperlayer()
        currentIdeaLabel = nil
        currentLine = nil
        currentPoint = nil
    }
    
    // MARK: - Gestures
    
    @objc private func addGestureAction(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: canvasView)
        switch sender.state {
        case .began:
            if let label = label(at: point) {
                currentIdeaLabel = label
                let line = Line(origin: label, destination: label.center)
                canvasView.layer.insertSublayer(line, at: 0)
                currentLine = line
            }
            
        case .ended:
            guard currentIdeaLabel != nil else {
                return
            }
            createIdea(at: point)
            
        case .cancelled:
            idle()
            
        case .changed:
            guard let currentLine = currentLine else {
                return
            }
            currentLine.updatePath(destination: point)
            currentPoint = point
            
        default:
            break
        }
    }
    
    @objc private func moveGestureAction(_ sender: UIPanGestureRecognizer) {
        guard sender.numberOfTouches == 2 else {
            guard let currentIdeaLabel = currentIdeaLabel else {
                return
            }
            currentIdeaLabel.viewModel.updateLocation(x: Float(currentIdeaLabel.center.x), y: Float(currentIdeaLabel.center.y))
            idle()
            UIFeedbackGenerator.success()
            return
        }
        
        let point = sender.location(in: canvasView)
        switch sender.state {
        case .began:
            if let label = label(at: point) {
                currentIdeaLabel = label
            }
            
        case .ended:
            guard let currentIdeaLabel = currentIdeaLabel else {
                return
            }
            currentIdeaLabel.viewModel.updateLocation(x: Float(currentIdeaLabel.center.x), y: Float(currentIdeaLabel.center.y))
            idle()
            UIFeedbackGenerator.success()
            
        case .changed:
            guard let currentIdeaLabel = currentIdeaLabel else {
                return
            }
            currentIdeaLabel.center = point
            
            lines.filter {
                $0.destination == currentIdeaLabel
            }
            .forEach {
                $0.updatePath(destination: point)
            }
            
            lines.filter {
                $0.origin == currentIdeaLabel
            }.forEach {
                $0.updatePath(origin: point)
            }
            
        default:
            break
        }
    }
    
    @objc private func doubleTapGesture(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: canvasView)
        if let label = label(at: point) {
            edit(label: label)
        }
    }
    
    private func bindViewModel() {
        
        guard let viewModel = viewModel else {
            return
        }
        widthConstraint?.constant = viewModel.canvasSize.width
        heightConstraint?.constant = viewModel.canvasSize.height
        scrollView.zoomScale = viewModel.zoomLevel
        let output =  viewModel.transform(input: .init(saveFileTrigger: saveFileTrigger.asObservable(),
                                                       viewDidAppearTrigger: viewDidAppearTrigger.asObservable(),
                                                       updateTrigger: updateRelay.asObservable(),
                                                       deleteTrigger: deleteRelay.asObservable()))
        
        disposeBag = DisposeBag {
            output.mapDriver.drive(with: self) { owner, models in
                owner.idle()
                models.forEach { model in
                    if let label = owner.label(for: model) {
                        label.viewModel = model
                    } else {
                        owner.insertLabel(for: model)
                    }
                }
                models.forEach { model in
                    if let label = owner.label(for: model),
                       let parent = model.idea.parent,
                       let parentLabel = owner.label(at: CGPoint(x: CGFloat(parent.location.x), y: CGFloat(parent.location.y))) {
                        if owner.lines.first(where: { $0.origin == parentLabel && $0.destination == label }) == nil {
                            let line = Line(origin: parentLabel, destination: label)
                            owner.canvasView.layer.insertSublayer(line, at: 0)
                        }
                    }
                }
                
                var index: Float = 0
                owner.labels.filter { !models.contains($0.viewModel) }.forEach { label in
                    label.popOut(delay: index * 0.05) {
                        label.removeFromSuperview()
                        owner.lines.filter { $0.origin == label || $0.destination == label }.forEach { $0.removeFromSuperlayer() }
                    }
                    index += 1
                }
                
                owner.lines.filter { $0.origin == nil || $0.destination == nil }.forEach { $0.removeFromSuperlayer() }
            }
            
            output.titleDriver.drive(with: self) { owner, title in
                owner.title = title
            }
            
            newIdeaRelay.asObservable().withUnretained(self).subscribe { owner, text in
                guard let currentIdeaLabel = owner.currentIdeaLabel, let currentPoint = owner.currentPoint else {
                    return
                }
                
                owner.navigationController?.presentedViewController?.dismiss(animated: true, completion: {
                    owner.viewModel.addIdea(parent: currentIdeaLabel.viewModel,
                                            with: text,
                                            location: Location(x: Float(currentPoint.x),
                                                               y: Float(currentPoint.y)))
                    owner.idle()
                })
                
            }
            
            editIdeaRelay.asObservable().withUnretained(self).subscribe { owner, text in
                guard let currentIdeaLabel = owner.currentIdeaLabel else {
                    return
                }
                currentIdeaLabel.text = text
                owner.updateRelay.accept((currentIdeaLabel.viewModel, text))
                owner.idle()
                owner.navigationController?.presentedViewController?.dismiss(animated: true)
            }
            
            deleteIdeaRelay.asObservable().withUnretained(self).subscribe { owner, _ in
                guard let currentIdeaLabel = owner.currentIdeaLabel else {
                    return
                }
                owner.deleteRelay.accept(currentIdeaLabel.viewModel)
                owner.idle()
            }
            
            output.closeDriver.drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }

        }
    }
    
    @objc func appMovedToBackground() {
        saveFileTrigger.accept(())
    }
}

extension MapViewController: UIScrollViewDelegate {
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        viewModel.zoomLevel = scrollView.zoomScale
    }
 
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasView
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard !scrollView.isZooming else {
            return
        }
        
        let contentOffset = scrollView.contentOffset
        if contentOffset.x < 200 {
            widthConstraint?.constant += 200
            scrollView.contentOffset = .init(x: contentOffset.x + 200,
                                             y: contentOffset.y)
            labels.forEach {
                $0.center = .init(x: $0.center.x + 200, y: $0.center.y)
            }
            
        }
        
        if contentOffset.y < 200 {
            heightConstraint?.constant += 200
            scrollView.contentOffset = .init(x: contentOffset.x,
                                             y: contentOffset.y + 200)
            labels.forEach {
                $0.center = .init(x: $0.center.x, y: $0.center.y + 200)
            }
            
        }
            lines.forEach { $0.updatePath() }
        
        if contentOffset.x + view.frame.width + 200 > canvasView.frame.width ||
                    contentOffset.y + view.frame.height + 200 > canvasView.frame.height {
            widthConstraint?.constant += 200
            heightConstraint?.constant += 200
        }
        viewModel.canvasSize = .init(width: widthConstraint?.constant ?? 0, height: heightConstraint?.constant ?? 0)
    }
    
}

extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: canvasView)
        return label(at: point) != nil 
    }
}
