///
/// Root View Controller
///
import UIKit
import Parse
import Bolts
import Contacts
var phoneNumber:String = ""
var code:String = ""
class loginView: UIViewController {
    @IBOutlet weak var nextButtonBot: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    var viewIndex = 0
    @IBAction func nextButton(sender: UIButton) {
        print (phoneNumber)
        if (viewIndex == 0){
        let params = NSDictionary(object: phoneNumber, forKey: "phoneNumber")
        PFCloud.callFunctionInBackground("sendVerificationCode", withParameters: params as [NSObject : AnyObject], block: {
            finished in
            
            print ("sent verification code")
            //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RedViewController") as! loginCode
            //pageDelegate.scrollToNextViewController()
            self.PageView!.scrollToNextViewController()
        })
        }
        else if (viewIndex == 1){
            let params: [String: String] = ["phoneNumber": phoneNumber, "phoneVerificationCode": code]
            PFCloud.callFunctionInBackground("verifyPhoneNumber", withParameters: params, block: {
                finished in
                print ("verified code")
                self.PageView!.scrollToNextViewController()
            })
        }
        else if (viewIndex == 2){
           self.performSegueWithIdentifier("leaveLogin", sender: self)
        }
        
        
    }
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
       // contactsync()
        
    }

    var PageView: pageView? {
        didSet {
            PageView?.pageViewDelegate = self
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let PageView = segue.destinationViewController as? pageView {
            self.PageView = PageView
        }
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
                        let name = "\(contact.givenName) \(contact.familyName)"
                        let contact: [String: String] = ["fullName": name, "phoneNumber": phone, "user" : ""]
                        friends.addObject(contact)
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
    func buttonAction() -> Void {
        print("hi")
    }
    func keyboardWillShow(notification: NSNotification) {
        //print ("keyboardwillshow")
        updateBottomLayoutConstraintWithNotification(notification)
        
    }
    func keyboardWillHide (notification: NSNotification) {
        // print ("keyboardwillhide")
        updateBottomLayoutConstraintWithNotification(notification)
        
    }
    func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let convertedKeyboardEndFrame = view.convertRect(keyboardEndFrame, fromView: view.window)
        nextButtonBot.constant = CGRectGetMaxY(view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame) + 25
 
    }
}

extension loginView: pageDelegate {
    
    func PageView(PageView: pageView,
        didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func PageView(PageView: pageView,
        didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
        print (index)
        viewIndex = index
    }
    
}





