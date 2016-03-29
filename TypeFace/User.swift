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
        print ("making subscription...")
        self.userRecordID = userRecordID
        let searchTerm = String(phoneNumber.characters.suffix(10))
        print (searchTerm)
       // let predicate = True
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let defaultContainer = CKContainer.defaultContainer()
        let publicDatabase = defaultContainer.publicCloudDatabase
        let subs = CKSubscription(recordType: "Message", predicate: NSPredicate(value: true),options: .FiresOnRecordCreation)
        subs.notificationInfo = CKNotificationInfo()
        subs.notificationInfo!.alertBody = "New item added"
        publicDatabase.saveSubscription(subs, completionHandler: {
            subscription, error in
        
         print (subscription)
            print (error)})
    
   
        
        
       
        
    }
    

}

