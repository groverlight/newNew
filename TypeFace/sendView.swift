//
//  sendView.swift
//  TypeFace
//
//  Created by Aaron Liu on 2/10/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit
import Contacts
class sendView: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var sendTable: UITableView!
    @IBAction func goBack(sender: AnyObject) {
        //self.performSegueWithIdentifier("goBacktoCamera", sender: self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    var wentPlayer = false
    @IBAction func goSend(sender: AnyObject) {
      //  self.dismissViewControllerAnimated(true, completion: nil)
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("playerView") as! playerView
        
        self.presentViewController(vc, animated: false, completion: { () -> Void in
            self.wentPlayer = true
        })

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if (friends.count == 0){
            contactsync()
        }
        print("sendview loaded")
        sendTable.delegate = self
        sendTable.dataSource = self
        sendTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if (friends.count == 0)
        {
            
        }
        panGesture?.enabled = false
    }

    override func viewWillAppear(animated: Bool) {
        sendTable.reloadData()
        if (self.wentPlayer == true){
            dismissViewControllerAnimated(true, completion: nil)
            self.wentPlayer = false
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // print("making friends count")
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       // print ("trying to make table")
        let cell:UITableViewCell = sendTable.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        let contact = friends[indexPath.row]
        cell.textLabel?.text = contact["fullName"] as? String
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func contactsync() -> Void {
        
        let contactStore = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            do {
                try contactStore.containersMatchingPredicate(CNContainer.predicateForContainerOfContactWithIdentifier(contactStore.defaultContainerIdentifier()))
            } catch _ {
                print("error: can't find contacts")
            }
            let keysTofetch = [CNContactPhoneNumbersKey,CNContactFamilyNameKey, CNContactGivenNameKey]
            let request = CNContactFetchRequest.init(keysToFetch: keysTofetch)
            
            do{
                try contactStore.enumerateContactsWithFetchRequest(request) {
                    contact, stop in
                    var phone = ""
                    for phoneNumber:CNLabeledValue in contact.phoneNumbers {
                        if (phoneNumber.label == "_$!<Mobile>!$_")
                        {
                            let phoneNum = phoneNumber.value as! CNPhoneNumber
                            phone = phoneNum.stringValue
                        }
                        
                        if (phone == "")
                        {
                            if (phoneNumber.label == "_$!<Home>!$_")
                            {
                                let phoneNum = phoneNumber.value as! CNPhoneNumber
                                phone = phoneNum.stringValue
                            }
                        }
                        if (phone == "")
                        {
                            if (phoneNumber.label == "_$!<Work>!$_")
                            {
                                let phoneNum = phoneNumber.value as! CNPhoneNumber
                                phone = phoneNum.stringValue
                            }
                        }
                        
                    }
                    //print (phone)
                    //print(contact.givenName)
                    //print(contact.familyName)
                    phone = self.numberFormatter(phone) as String
                    let name:String = "\(contact.givenName) \(contact.familyName)"
                    let containsLetter =  name.rangeOfCharacterFromSet(NSCharacterSet.letterCharacterSet())
                    
                    if (containsLetter != nil){
                        let contact: [String: String] = ["fullName": name, "phoneNumber": phone, "user" : ""]
                        friends.addObject(contact)
                    }
                }
            } catch let err{
                print(err)
            }
            //sort friends after syncing
            let sortArr:NSArray =
            friends.sortedArrayUsingComparator(){
                
                (p1:AnyObject!, p2:AnyObject!) -> NSComparisonResult in
                
                if p1["fullName"] as! String > p2["fullName"] as! String{
                    return NSComparisonResult.OrderedDescending
                }
                else{
                    return NSComparisonResult.OrderedAscending
                }
            }
            friends = NSMutableArray(array:sortArr)
            break
        case .Denied, .NotDetermined:
            contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    do {
                        try contactStore.containersMatchingPredicate(CNContainer.predicateForContainerOfContactWithIdentifier(contactStore.defaultContainerIdentifier()))
                    } catch _ {
                        print("error: can't find contacts")
                    }
                    let keysTofetch = [CNContactPhoneNumbersKey,CNContactFamilyNameKey, CNContactGivenNameKey]
                    let request = CNContactFetchRequest.init(keysToFetch: keysTofetch)
                    
                    do{
                        try contactStore.enumerateContactsWithFetchRequest(request) {
                            contact, stop in
                            print(contact.givenName)
                            print(contact.familyName)
                        }
                    } catch let err{
                        print(err)
                    }
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            //let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            
                        })
                    }
                }
            })
            break
        default:
            break
        }
        
        
    }
    func numberFormatter(var mobileNumber: NSString) -> NSString {
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("(", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString(")", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("-", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("+", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString(".", withString: "")
        
        let length = mobileNumber.length
        if(length > 10)
        {
            mobileNumber = mobileNumber.substringToIndex(length-10)
        }
        
        return mobileNumber
    }

}
