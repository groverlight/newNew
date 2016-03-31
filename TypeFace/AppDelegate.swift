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

        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
       // fetchNotificationChanges()
        
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
                userFull = User(userRecordID: (userRecord?.recordID)!,phoneNumber:phoneNumber)
                NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "timerFunc:", userInfo: nil, repeats: true)

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
                        //recentMessages = userRecord!["messages"] as! Array<[String:String]>
                        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
                        let searchTerm = String(userFull!.phoneNumber!.characters.suffix(10))
                        // print (searchTerm)
                        let predicate = NSPredicate(format: "toUser = '\(searchTerm)'")
                        let query = CKQuery(recordType: "Message", predicate: predicate)
                        
                        publicDB.performQuery(query, inZoneWithID:  nil) { results, error in
                            print (results)
                            messages = results! as Array<CKRecord>
                            messages.sortInPlace {
                                item1, item2 in
                                let date1 = item1["time"] as! NSNumber
                                let date2 = item2["time"]as! NSNumber
                                return date1.compare(date2) == NSComparisonResult.OrderedDescending
                            }
                            print (messages)
                        }
                           /* let publicDB = CKContainer.defaultContainer().publicCloudDatabase
                            let searchTerm = String(userFull!.phoneNumber!.characters.suffix(10))
                            // print (searchTerm)
                            let predicate = NSPredicate(format: "toUser = '\(searchTerm)'")
                            let query = CKQuery(recordType: "Message", predicate: predicate)
                            
                            publicDB.performQuery(query, inZoneWithID:  nil) { results, error in
                                print (results)
                                messages = results!
                            }*/

                            //print (userFull)
                            
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
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {print("got notification1")}
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print ("got notification2")
        
        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        if cloudKitNotification.notificationType == .Query {
            let queryNotification = cloudKitNotification as! CKQueryNotification
            if queryNotification.queryNotificationReason == .RecordDeleted {
                // If the record has been deleted in CloudKit then delete the local copy here
            } else {
                // If the record has been created or changed, we fetch the data from CloudKit
                let database: CKDatabase
                if queryNotification.isPublicDatabase {
                    database = CKContainer.defaultContainer().publicCloudDatabase
                } else {
                    database = CKContainer.defaultContainer().privateCloudDatabase
                }
                database.fetchRecordWithID(queryNotification.recordID!, completionHandler: { (record: CKRecord?, error: NSError?) -> Void in
                    guard error == nil else {
                          completionHandler(UIBackgroundFetchResult.NoData)
                        // Handle the error here
                        return
                    }
                    
                    if queryNotification.queryNotificationReason == .RecordUpdated {
                        // Use the information in the record object to modify your local data
                    } else {
                        // Use the information in the record object to create a new local object
                    }
                })
            }
        }
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    func fetchNotificationChanges() {
        let operation = CKFetchNotificationChangesOperation(previousServerChangeToken: nil)
        
        var notificationIDsToMarkRead = [CKNotificationID]()
        
        operation.notificationChangedBlock = { (notification: CKNotification) -> Void in
            // Process each notification received
            print (notification.notificationType)
            if notification.notificationType == .Query {
                let queryNotification = notification as! CKQueryNotification
               // let reason = queryNotification.queryNotificationReason
               // let recordID = queryNotification.recordID
                
                // Do your process here depending on the reason of the change
                
                // Add the notification id to the array of processed notifications to mark them as read
                notificationIDsToMarkRead.append(queryNotification.notificationID!)
            }
        }
        
        operation.fetchNotificationChangesCompletionBlock = { (serverChangeToken: CKServerChangeToken?, operationError: NSError?) -> Void in
            guard operationError == nil else {
                // Handle the error here
                return
            }
            
            // Mark the notifications as read to avoid processing them again
            let markOperation = CKMarkNotificationsReadOperation(notificationIDsToMarkRead: notificationIDsToMarkRead)
            markOperation.markNotificationsReadCompletionBlock = { (notificationIDsMarkedRead: [CKNotificationID]?, operationError: NSError?) -> Void in
                guard operationError == nil else {
                    // Handle the error here
                    return
                }
            }
            
            let operationQueue = NSOperationQueue()
            operationQueue.addOperation(markOperation)
        }
        
        let operationQueue = NSOperationQueue()
        operationQueue.addOperation(operation)
    }
    func timerFunc(timer : NSTimer){
        print("timerfunc")
        if (userFull != nil){
            let privateDB = CKContainer.defaultContainer().privateCloudDatabase
            privateDB.fetchRecordWithID((userFull?.userRecordID)!, completionHandler: { (Record, ErrorType) -> Void in
                Record!["message"] = recentMessages
            })
            let publicDB = CKContainer.defaultContainer().publicCloudDatabase
            let searchTerm = String(userFull!.phoneNumber!.characters.suffix(10))
            // print (searchTerm)
            let predicate = NSPredicate(format: "toUser = '\(searchTerm)'")
            let query = CKQuery(recordType: "Message", predicate: predicate)
            
            publicDB.performQuery(query, inZoneWithID:  nil) { results, error in
                print (results)
                if (messages.count == 0){
                    messages = results! as Array<CKRecord>
                    messages.sortInPlace {
                        item1, item2 in
                        let date1 = item1["time"] as! NSNumber
                        let date2 = item2["time"] as! NSNumber
                        
                        return date1.compare(date2) == NSComparisonResult.OrderedDescending
                    }
                    
                    var uniqueArray = Array<CKRecord>()
                    let names = NSMutableSet()
                    
                    for record in messages {
                        
                        let destinationName = record["fromUser"] as! String
                        
                        if (!names.containsObject(destinationName)) {
                            
                            uniqueArray.append(record)
                            names.addObject(destinationName)
                            
                            
                        }
                        else
                        {
                            
                            for var i = 0; i < uniqueArray.count; ++i
                            {
                                let record2 = uniqueArray[i];
                                if (record2["fromUser"] as! String == record["fromUser"] as! String)
                                {
                                    uniqueArray[i] = record;
                                }
                            }
                            
                        }
                        
                    }
                    messages = uniqueArray as [CKRecord];
                    
                }
                else{
                    let results = results! as Array<CKRecord>
                    for result in results{
                        for var i=0; i < messages.count; ++i{
                            if messages[i]["fromUser"] as! String == result{
                                messages[i] = result
                            }
                        
                        }
                    }
                }
                self.organizeMessages()
                
                
                print (messages)
            }
        
    }
        

    }
    func organizeMessages(){
        
        for message in messages{
            var addToRecent: Bool = true
            for var i = 0; i < recentMessages.count; ++i {
            if (recentMessages[i]["phone"]! as! String == message["phone"] as! String){
               // dictionary["video"] = message["video"]
                recentMessages[i]["videos"] = message["videos"]
                addToRecent = false
            }
        }
        if (addToRecent == true){
            let dictionary:[String:AnyObject] = ["fromUser":message["fromUser"] as! String, "fullName":message["name"] as! String, "phone":message["phone"] as! String, "video":message["videos"] as! Array<CKRecord>]
            recentMessages.append(dictionary)
            print (recentMessages)
        }
    }
    }
}
