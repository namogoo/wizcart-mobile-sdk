//
//  AppDelegate.swift
//  WizCart-Test
//
//  Created by Amir Zucker on 18/05/2020.
//  Copyright © 2020 Namogoo. All rights reserved.
//

import UIKit
import WizCart

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {

        AppManager.shared.setRealUserConfiguration()
                
        return true
    }
}
