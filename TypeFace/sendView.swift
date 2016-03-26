//
//  sendView.swift
//  TypeFace
//
//  Created by Aaron Liu on 2/10/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit
import Contacts
import CloudKit
class sendView: UIViewController,UITableViewDelegate,UITableViewDataSource,BDKCollectionIndexViewDelegate {
    @IBOutlet weak var sendTable: UITableView!

    @IBAction func goBack(sender: AnyObject) {
        //self.performSegueWithIdentifier("goBacktoCamera", sender: self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBOutlet weak var navBar: UINavigationBar!
    var wentPlayer = false
    @IBAction func goSend(sender: AnyObject) {

        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("playerView") as! playerView
       

        for path in checkedIndexPath {
            
            let contact = sectionsArray[path.section][path.row] as! [String:String]
            print (contact)
            if (contact["phoneNumber"] != nil){
                print("composing message...")
                var asset:CKAsset
                var assetArray = [CKAsset]()
                for var i = 0; i < arrayofText.count; ++i{
                    asset = CKAsset(fileURL: NSURL.fileURLWithPath("\(NSTemporaryDirectory())\(i+1).m4v" ))
                    assetArray.append(asset)
                }
      
                let message = CKRecord(recordType: "Message")
                message["videos"] = assetArray
                message["text"] = arrayofText
                message["toUser"] = String(userFull!.phoneNumber!.characters.suffix(10))
                message["name"]  = ("\(userFull!.firstName!) \(userFull!.lastName!)") //
                message["time"] = NSDate().timeIntervalSince1970 * 1000
                message ["fromUser"] = "\(userFull!.userRecordID)"
                let publicDB = CKContainer.defaultContainer().publicCloudDatabase
                publicDB.saveRecord(message) { savedRecord, error in
                    // handle errors here
                    print (error)
                }
                print(message)
            }
            }
        
    
    
        self.presentViewController(vc, animated: false, completion: { () -> Void in
            self.wentPlayer = true
        })

        
    }
    var tableBounds: CGRect!
    var indexTitles: NSArray?
    var sectionsArray = Array(count: 27, repeatedValue: Array(count: 0, repeatedValue: NSDictionary()))
    var checkedIndexPath = [NSIndexPath]()
    //var peopleinArray: NSMutableArray?
    override func viewDidLoad() {
        super.viewDidLoad()
        if (friends.count == 0){
            contactsync()
        }
        self.sendTable.sectionHeaderHeight = 5
        indexTitles = ["🕒","A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        let indexList = BDKCollectionIndexView(frame: CGRectMake(self.view.bounds.size.width-28,CGRectGetMinY(self.sendTable.frame), 28, self.view.bounds.size.height - navBar.bounds.size.height
            ), indexTitles: indexTitles as! [AnyObject])
        indexList.font = UIFont(name: "Avenir Next", size: 10)
        indexList.delegate = self
        self.view.addSubview(indexList)
        self.view.bringSubviewToFront(indexList)
        //self.sendTable.transform = CGAffineTransformMakeTranslation(1500, 0)
        //self.navBar.transform = CGAffineTransformMakeTranslation(1500, 0)
      

        sendTable.delegate = self
        sendTable.dataSource = self
       // sendTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        panGesture?.enabled = false
    }

    override func viewWillAppear(animated: Bool) {
        self.sendTable.reloadData()
        checkedIndexPath.removeAll()
        if (self.wentPlayer == true){
            self.dismissViewControllerAnimated(true, completion: nil)
            self.wentPlayer = false
        }
        filterFriends()

    }
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(1, delay: 0.0, options: [], animations: {
            self.sendTable.transform = CGAffineTransformMakeTranslation(0, 0)
            self.navBar.transform = CGAffineTransformMakeTranslation(0, 0)
            self.view.layoutIfNeeded()
            }, completion: nil)

    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (indexTitles?.count)!
    }
     func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vw = UIView(frame: CGRect.zero)
        if (sectionsArray[section].count > 0 ){
        let label = UILabel(frame: CGRectMake(self.view.bounds.size.width/CGFloat(2)-7.5,-7.5,20,20))
        label.textAlignment = NSTextAlignment.Center
        //label.layer.borderWidth = 1
       // label.layer.borderColor = UIColor.grayColor()().CGColor
        label.layer.backgroundColor = UIColor.grayColor().CGColor//UIColor.init(colorLiteralRed: 1.00, green: 0.28, blue: 0.44, alpha: 1.0).CGColor
        label.layer.cornerRadius = label.bounds.size.width/2
        label.text = indexTitles![section] as? String
        label.font = UIFont(name: "AvenirNext", size: 10)
        label.textColor = UIColor.whiteColor()
        label.alpha = 0.7
        vw.addSubview(label)
        
        }
        return vw
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // print("making friends count")
        let count = sectionsArray[section].count
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       // print ("trying to make table")
        let cell:UITableViewCell = sendTable.dequeueReusableCellWithIdentifier("sendCell")! as UITableViewCell

        let contact = sectionsArray[indexPath.section][indexPath.row]
       // cell.textLabel?.text = contact["fullName"] as? String
        cell.textLabel?.textAlignment = NSTextAlignment.Left
        
        let label:UILabel = (cell.contentView.subviews[0]) as! UILabel
        let label2:UILabel = (cell.contentView.subviews[1]) as! UILabel
        let label3:UILabel = (cell.contentView.subviews[2]) as! UILabel
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.blackColor().CGColor
        label2.text = contact["fullName"] as? String
        label2.font = UIFont(name: "AvenirNext-Medium", size: 17)
        label2.textColor = UIColor.whiteColor()
        label3.text = contact["phoneNumber"] as? String
        if (self.checkedIndexPath.count > 0){
            
            if ( self.checkedIndexPath.contains(indexPath)){
                label.text = "✓"
            }
            else{
                label.text = ""
            }

        }
        else{
            label.text = ""
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.sendTable.cellForRowAtIndexPath(indexPath)
        let label:UILabel = (cell!.contentView.subviews[0]) as! UILabel
        if (label.text == "✓"){
          let index =  self.checkedIndexPath.indexOf(indexPath)
          self.checkedIndexPath.removeAtIndex(index!)
        }
        else{
            self.checkedIndexPath.append(indexPath)
        }
        self.sendTable.reloadData()
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
                   // print(contact.familyName)
                    phone = self.numberFormatter(phone) as String
                    let name:String = "\(contact.givenName) \(contact.familyName)"
                    let containsLetter =  name.rangeOfCharacterFromSet(NSCharacterSet.letterCharacterSet())
                    
                    if (containsLetter != nil){
                        let contact: [String: String] = ["fullName": name, "phoneNumber": phone, "user" : ""]
                        friends.append(contact)
                    }
                }
            } catch let err{
                print(err)
            }

            friends = friends.sort { p1, p2 in
                let name1 = p1["fullName"] as! String
                let name2 = p2["fullName"] as! String
                    return name1 < name2
            }
        
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
    func filterFriends(){
        for people:NSDictionary in friends{
            let fullName = people["fullName"] as! String
           // fullName.
            
            let index = fullName.startIndex.advancedBy(0)
            let nameIndex = Int(fullName[index].utf8Value()) - 64
            
            if (nameIndex > 0 ){
                if (nameIndex < 26){
                    sectionsArray[nameIndex].append(people)
                }
            }
            //sectionsArray[
        }
        //print (sectionsArray)
        //print (sectionsArray.count)
        
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
    func collectionIndexView(collectionIndexView: BDKCollectionIndexView!, isPressedOnIndex pressedIndex: UInt, indexTitle: String!) {
        print ("selected")
        let intIndex = Int(pressedIndex)
        let path = NSIndexPath(forRow: 0, inSection: intIndex)
        if (sectionsArray[intIndex].count > 0){
            self.sendTable.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.None, animated: true)
        }
        
    }
    
}
extension Character {
    func utf8Value() -> UInt8 {
        for s in String(self).utf8 {
            return s
        }
        return 0
    }
    
    func utf16Value() -> UInt16 {
        for s in String(self).utf16 {
            return s
        }
        return 0
    }
    
    func unicodeValue() -> UInt32 {
        for s in String(self).unicodeScalars {
            return s.value
        }
        return 0
    }
}
