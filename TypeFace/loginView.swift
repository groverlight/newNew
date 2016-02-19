///
/// Root View Controller
///
import UIKit
import Contacts
var phoneNumber:NSString = ""
class loginView: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        
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

}

extension loginView: pageDelegate {
    
    func PageView(PageView: pageView,
        didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func PageView(PageView: pageView,
        didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}



