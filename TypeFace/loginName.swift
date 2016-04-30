//
//  loginName.swift
//  TypeFace
//
//  Created by Aaron Liu on 2/11/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit
import CloudKit

class loginName: UIViewController {
   
    @IBOutlet weak var AlerView: UIView!
    override func viewDidLoad() {
        AlerView.hidden = false

        self.AlerView.layer.cornerRadius = 20
        


    }
    @IBAction func iCloudAction(sender: AnyObject) {
       
        self.iCloudLogin({ (success) -> () in
            if success {
               

               // print ("success")
            } else {
                ("error")
                // TODO error handling
            }
        })
    }


    //var PageView: pageView?
    func timerFunc(timer : NSTimer){
        //  print("timerfunc")
        if (userFull != nil){

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
                            
                            for i in 0 ..< uniqueArray.count
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
                        for i in 0 ..< messages.count{
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
            for i in 0 ..< recentMessages.count {
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
                              //  self.PageView!.scrollToNextViewController()
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
