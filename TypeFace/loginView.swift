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
        self.PageView!.scrollToNextViewController()

        if (viewIndex == 0){
            PFAnonymousUtils.logInWithBlock({ (user, error) -> Void in
                if (error != nil){
                    print("Anonymous login failed.")
                }
                else{
                    print ("Anonymous user logged in ")
                    PFCloud.callFunctionInBackground("sendVerificationCode", withParameters: ["phoneNumber":phoneNumber], block: {
                        (result: AnyObject?, error: NSError?) in
                        print ("sent verification code")
                        if (error == nil){
                        print ("no error")
                        //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RedViewController") as! loginCode
                        //pageDelegate.scrollToNextViewController()
                        self.PageView!.scrollToNextViewController()
                        }
                        else{
                            print (error)
                        }
                    })
                }
            
        })


        }
        else if (viewIndex == 1){
            print (code)
            PFCloud.callFunctionInBackground("verifyPhoneNumber", withParameters: ["phoneNumber": phoneNumber, "phoneVerificationCode": code], block: {
                (result: AnyObject?, error: NSError?) in
                print ("verified code")
                if (error == nil){
                    self.PageView!.scrollToNextViewController()
                }
                else{
                    print (error)
                }
            })
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





