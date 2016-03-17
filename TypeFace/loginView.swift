///
/// Root View Controller
///
import UIKit

import Contacts
import CloudKit
var phoneNumber:String = ""
var code:String = ""
var cloudManager: CloudManager = CloudManager()
var userFull: User?
class loginView: UIViewController {
    var publicDB = CKContainer.defaultContainer().publicCloudDatabase
    @IBOutlet weak var nextButtonBot: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    var viewIndex = 0
    @IBAction func nextButton(sender: UIButton) {
               print (phoneNumber)
       
        if (viewIndex == 0){
            self.iCloudLogin({ (success) -> () in
                if success {
                    self.PageView!.scrollToNextViewController()
                } else {
                    // TODO error handling
                }
            })


        }
        else if (viewIndex == 1){
            let greatID = CKRecordID(recordName: phoneNumber)
            
            publicDB.fetchRecordWithID(greatID) { fetchedPlace, error in
       
            }
            self.PageView!.scrollToNextViewController()

        }
        else if (viewIndex == 2){
            print ("hi")
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("camera") as! cameraView
            frontWindow?.rootViewController = vc

        }
        
        
    }
    override func viewDidLoad() {
        panGesture?.enabled = false

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
    private func iCloudLogin(completionHandler: (success: Bool) -> ()) {
        cloudManager.requestPermission { (granted) -> () in
            if !granted {
                let iCloudAlert = UIAlertController(title: "iCloud Error", message: "There was an error connecting to iCloud. Check iCloud settings by going to Settings > iCloud.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                
                iCloudAlert.addAction(okAction)
                self.presentViewController(iCloudAlert, animated: true, completion: nil)
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





