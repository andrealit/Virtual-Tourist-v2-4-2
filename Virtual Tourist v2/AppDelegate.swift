//
//  AppDelegate.swift
//  Virtual Tourist v2
//
//  Created by Andrea Tongsak on 7/18/19.
//  Copyright © 2019 Andrea Tongsak. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Virtual_Tourist_v2")!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

}

