//
//  AppDelegate.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        
        let navController = UINavigationController(rootViewController: PostListViewController())
        navController.navigationBar.isHidden = true
        window?.rootViewController = navController
                                                            
        
        return true
    }
}

