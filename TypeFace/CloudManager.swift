//
//  CloudManager.swift
//  iCloudLogin
//
//  Created by Catarina Simões on 16/11/14.
//  Copyright (c) 2014 velouria.org. All rights reserved.
//

import CloudKit

class CloudManager: NSObject {
   
    var defaultContainer: CKContainer?
    
    override init() {
        defaultContainer = CKContainer.defaultContainer()
    }

    func requestPermission(completionHandler: (granted: Bool) -> ()) {
        defaultContainer!.requestApplicationPermission(CKApplicationPermissions.UserDiscoverability, completionHandler: { applicationPermissionStatus, error in
            if applicationPermissionStatus == CKApplicationPermissionStatus.Granted {
                completionHandler(granted: true)
            } else {
                // very simple error handling
                completionHandler(granted: false)
            }
        })
    }
    
    func getUser(completionHandler: (success: Bool, user: User?) -> ()) {
        defaultContainer!.fetchUserRecordIDWithCompletionHandler { (userRecordID, error) in
            if error != nil {
                completionHandler(success: false, user: nil)
            } else {
                let privateDatabase = self.defaultContainer!.privateCloudDatabase
                privateDatabase.fetchRecordWithID(userRecordID!, completionHandler: { (userRecord: CKRecord?, anError) -> Void in
                    if (error != nil) {
                        completionHandler(success: false, user: nil)
                    } else {
                        //print (error)
                        userRecord!["phoneNumber"] = phoneNumber
                        userFull?.phoneNumber = phoneNumber
                        //print (userRecord)
                        privateDatabase.saveRecord(userRecord!, completionHandler: { record, error in
                            //...
                        })
                        let user = User(userRecordID: userRecordID!, phoneNumber:phoneNumber)
                        completionHandler(success: true, user: user)
                    }
                })
            }
        }
    }

    func getUserInfo(user: User, completionHandler: (success: Bool, user: User?) -> ()) {
        defaultContainer!.discoverUserInfoWithUserRecordID(user.userRecordID) { (info, fetchError) in
            if fetchError != nil {
                completionHandler(success: false, user: nil)
            } else {
                user.firstName = info!.displayContact!.givenName
                user.lastName = info!.displayContact!.familyName
                completionHandler(success: true, user: user)
            }
        }
    }

}
