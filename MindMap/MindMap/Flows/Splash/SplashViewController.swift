//
//  SplashViewController.swift
//  MindMap
//
//

import UIKit
import Lottie

class SplashViewController: UIViewController {
    
    private let animation = Animation.named("appStartAnimation")
    private let imageName = "background"
    private let animationSpeed: CGFloat = 3
    
    private var backgroundImageView: UIImageView? = UIImageView()
    private var animationView: AnimationView? = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startAnimation()
    }
    
}

private extension SplashViewController {
    
    func startAnimation() {
        
        backgroundImageView?.image = UIImage(named: imageName)
        backgroundImageView?.frame = view.bounds
        view.addSubview(backgroundImageView!)
        view.bringSubviewToFront(backgroundImageView!)
        
        animationView?.animation = animation
        animationView?.contentMode = .center
        animationView?.animationSpeed = animationSpeed
        animationView?.loopMode = .playOnce
        view.addSubview(animationView!)
        animationView?.frame = view.bounds
        view.bringSubviewToFront(animationView!)
        
        animationView?.play { [weak self] _ in
            let viewController = FileListConfigurator.configure()
            self?.view.window?.rootViewController = UINavigationController(rootViewController: viewController)
        }
        
    }
    
}
