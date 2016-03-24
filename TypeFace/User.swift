//
//  User.swift
//  iCloudLogin
//
//  Created by Catarina Simões on 16/11/14.
//  Copyright (c) 2014 velouria.org. All rights reserved.
//

import CloudKit

class User: NSObject {
   
    var userRecordID: CKRecordID
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    
    init(userRecordID: CKRecordID, phoneNumber:String) {
        self.userRecordID = userRecordID
        let searchTerm = String(phoneNumber.characters.suffix(10))
        print (searchTerm)
        let predicate = NSPredicate(format: "toUser = '7022808866'")
        print ("making subscription...")
        let subscription = CKSubscription(recordType: "Message", predicate: predicate, options: [.FiresOnRecordCreation, .FiresOnRecordUpdate])
        
        let info = CKNotificationInfo()
        //info.soundName = UILocalNotificationDefaultSoundName
        info.shouldBadge = true
        info.alertBody = "sup dude!"
        info.shouldSendContentAvailable = true;
        subscription.notificationInfo = info
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        publicDB.saveSubscription(subscription) { subscription, error in
            print (subscription)
            print (error)//...
        }

    }

}

