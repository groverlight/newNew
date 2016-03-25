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
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        
        let subscription = CKSubscription(
            recordType: "Spaceships",
            predicate: NSPredicate(format: "TRUEPREDICATE"),
            options: .FiresOnRecordCreation
        )
        
        let info = CKNotificationInfo()
        
        info.alertBody = "New Spaceship Entered the Fleet!"
        info.shouldBadge = true
        
        subscription.notificationInfo = info
        
        publicDB.saveSubscription(subscription) { record, error in }

        

    }

}

