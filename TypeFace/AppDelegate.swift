//
//  AppDelegate.swift
//  
//
//  Created by Aaron Liu on 2/9/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit
import CloudKit
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    //var window: UIWindow?
    //var frontWindow: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
       window?.rootViewController!.view.hidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let front:UIViewController =  storyboard.instantiateViewControllerWithIdentifier("camera") as UIViewController
        let vc = storyboard.instantiateViewControllerWithIdentifier("login") as UIViewController

        //if (PFUser.currentUser() == nil) // needs some condition to go to login
        frontWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
        let defaultContainer = CKContainer.defaultContainer()
        defaultContainer.fetchUserRecordIDWithCompletionHandler { (userRecordID, error) in
            
            let privateDatabase = cloudManager.defaultContainer!.privateCloudDatabase
            privateDatabase.fetchRecordWithID(userRecordID!, completionHandler: { (userRecord: CKRecord?, anError) -> Void in
                print (userRecord)
                userFull = User(userRecordID: (userRecord?.recordID)!)
                dispatch_async(dispatch_get_main_queue()){
                    frontWindow?.windowLevel = UIWindowLevelStatusBar
                    frontWindow?.startSwipeToOpenMenu()
                    frontWindow?.makeKeyAndVisible();
                    application.statusBarStyle = .LightContent
                    }
                if (userRecord!["phoneNumber"] == nil){
                    dispatch_async(dispatch_get_main_queue()) {

                    frontWindow?.rootViewController = vc
                    }
                }
                else{
                    defaultContainer.discoverUserInfoWithUserRecordID(userRecord!.recordID) { (info, fetchError) in
                     
                            userFull?.firstName = info!.displayContact!.givenName
                            userFull?.lastName = info!.displayContact!.familyName
                            userFull?.phoneNumber = userRecord!["phoneNumber"] as? String
                            print (userFull)
                        
                        }
                    
                    dispatch_async(dispatch_get_main_queue()) {

                    frontWindow?.rootViewController = front
                    
                    let blur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
                    let blurView = UIVisualEffectView(effect: blur)
                    blurView.frame = UIScreen.mainScreen().bounds
                    blurView.alpha = 1
                    frontWindow?.insertSubview(blurView, atIndex: 0)
                    
                    }

                }
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.window?.rootViewController!.view.hidden = false
                }
            })}

        
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

