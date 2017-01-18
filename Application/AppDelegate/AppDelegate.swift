//

//
//  AppDelegate.swift
//  Application
//  Created by Alok Singh on 01/07/16.
//  Copyright (c) 2016 Swan Music. All rights reserved.
//



import UIKit
import CoreData

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       /**
         The first thing which needs to be called when the app starts is
         AppCommonFunctions.sharedInstance.prepareForStartUp
        */
        AppCommonFunctions.sharedInstance.prepareForStartUp(application,didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        AppCommonFunctions.sharedInstance.setupBackgroundAudioSettings()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        AppCommonFunctions.sharedInstance.setupBackgroundAudioSettings()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        AppCommonFunctions.sharedInstance.setupBackgroundAudioSettings()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppCommonFunctions.sharedInstance.setupBackgroundAudioSettings()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        DatabaseManager.sharedInstance.saveChanges()
    }
}
