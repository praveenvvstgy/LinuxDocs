//
//  MainTabBarController.swift
//  LinuxDocs
//
//  Created by Praveen Gowda I V on 3/24/15.
//  Copyright (c) 2015 Praveen Gowda I V. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, SKSplashDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        penguinSplash()
    }
    
    func penguinSplash() -> Void {
        let penguinSplashIcon: SKSplashIcon = SKSplashIcon(image: UIImage(named: "penguin"), animationType: SKIconAnimationType.Bounce)
        let penguinColor = UIColor(red:0.13, green:0.17, blue:0.22, alpha:1)
        let splashView =  SKSplashView(splashIcon: penguinSplashIcon, backgroundColor: penguinColor, animationType: SKSplashAnimationType.None)
        splashView.delegate = self
        splashView.animationDuration = 3
        self.view.addSubview(splashView)
        splashView.startAnimation()
    }
}
