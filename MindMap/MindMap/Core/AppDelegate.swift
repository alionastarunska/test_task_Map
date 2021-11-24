//
//  AppDelegate.swift
//  MindMap
//
//

import UIKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.overrideUserInterfaceStyle = .light
        }
        
        window?.makeKeyAndVisible()
        window?.rootViewController = SplashViewController()
        return true
        
    }

}
