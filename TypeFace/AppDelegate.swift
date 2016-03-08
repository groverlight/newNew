//
//  AppDelegate.swift
//  
//
//  Created by Aaron Liu on 2/9/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    //var window: UIWindow?
    //var frontWindow: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.enableLocalDatastore()
        Parse.setApplicationId("CP7uHBTadzC2UNvEp2yhpAIv1GEM1gdiPHuzwtpr",
            clientKey: "DQj2oBjtZZqSHpbcPzG20poPjEdwaVxI1xvZ5NzT")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let front:UIViewController =  storyboard.instantiateViewControllerWithIdentifier("camera") as UIViewController
        let vc = storyboard.instantiateViewControllerWithIdentifier("login") as UIViewController

        //if (PFUser.currentUser() == nil) // needs some condition to go to login
        frontWindow = UIWindow(frame: UIScreen.mainScreen().bounds)

        if (false
            ){
                
                frontWindow?.rootViewController = vc
        }
        else{
            
            frontWindow?.rootViewController = front;
        }
        frontWindow?.windowLevel = UIWindowLevelStatusBar
        frontWindow?.startSwipeToOpenMenu()
        frontWindow?.makeKeyAndVisible();
        application.statusBarStyle = .LightContent
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: blur)
        let BlurSurface = UIView.init(frame: UIScreen.mainScreen().bounds)
        blurView.frame = UIScreen.mainScreen().bounds
        BlurSurface.addSubview(blurView)
        //BlurSurface.alpha = 0
        print(BlurSurface)
        frontWindow?.insertSubview(BlurSurface, atIndex: 0)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

   
}

