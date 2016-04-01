//
//  loginName.swift
//  TypeFace
//
//  Created by Aaron Liu on 2/11/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit
import CloudKit

class loginName: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var iCloudButton: UIButton!
    
    @IBAction func iCloudAction(sender: AnyObject) {
        self.iCloudLogin({ (success) -> () in
            if success {
               
                dispatch_async(dispatch_get_main_queue()) {
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("camera") as! cameraView
                    frontWindow?.rootViewController = vc
                    let blur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
                    let blurView = UIVisualEffectView(effect: blur)
                    blurView.frame = UIScreen.mainScreen().bounds
                    
                    frontWindow?.insertSubview(blurView, atIndex: 0)
                    NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "timerFunc:", userInfo: nil, repeats: true)

                }
               // print ("success")
            } else {
                ("error")
                // TODO error handling
            }
        })
    }
    func timerFunc(timer : NSTimer){
        //  print("timerfunc")
        if (userFull != nil){
            // print ("userfull not init")
            /* let privateDB = CKContainer.defaultContainer().privateCloudDatabase
            privateDB.fetchRecordWithID((userFull?.userRecordID)!, completionHandler: { (Record, ErrorType) -> Void in
            if (ErrorType == nil){
            //Record!["message"] = recentMessages
            
            }
            })*/
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
                
                
                
                //print (messages)
                self.organizeMessages()
            }
            
        }
        
        
    }
    func organizeMessages(){
        print ("organize messages")
        print (recentMessages)
        for message in messages{
            var addToRecent: Bool = true
            for var i = 0; i < recentMessages.count; ++i {
                if (recentMessages[i]["phone"]! as! String == message["phone"] as! String){
                    // dictionary["video"] = message["video"]
                    print ("false")
                    recentMessages[i]["videos"] = message["videos"]
                    addToRecent = false
                }
            }
            if (addToRecent == true){
                print ("addtoRecent")
                let dictionary:[String:AnyObject] = ["fromUser":message["fromUser"] as! String, "fullName":message["name"] as! String, "phone":message["phone"] as! String, "video":message["videos"] as! Array<CKRecord>]
                recentMessages.append(dictionary)
                let privateDB = CKContainer.defaultContainer().privateCloudDatabase
                privateDB.fetchRecordWithID((userFull?.userRecordID)!, completionHandler: { (Record, ErrorType) -> Void in
                    if (ErrorType == nil){
                        let record:CKRecordValue = recentMessages
                       // Record!["message"] = record
                        
                    }
                    print (recentMessages)
                })
            }
        }
    }

    private func iCloudLogin(completionHandler: (success: Bool) -> ()) {
        cloudManager.requestPermission { (granted) -> () in
            if !granted {
                let iCloudAlert = UIAlertController(title: "iCloud Error", message: "There was an error connecting to iCloud. Check iCloud settings by going to Settings > iCloud.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                    let url = NSURL(string: "prefs:root=CASTLE")
                    UIApplication.sharedApplication().openURL(url!)
                })
                
                iCloudAlert.addAction(okAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(iCloudAlert, animated: true, completion: nil)
                }
            } else {
                cloudManager.getUser({ (success, let user) -> () in
                    if success {
                        userFull = user
                        
                        cloudManager.getUserInfo(userFull!, completionHandler: { (success, user) -> () in
                            if success {
                                
                                completionHandler(success: true)
                            }
                        })
                    } else {
                        // TODO error handling
                    }
                })
            }
        }
    }
}
