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
var twilioView: UIWebView = UIWebView(frame: CGRect.zero)
class loginView: UIViewController {
    var publicDB = CKContainer.defaultContainer().publicCloudDatabase
    
    @IBOutlet weak var oneLabel: UILabel!
    
    @IBOutlet weak var twoLabel: UILabel!
    
    @IBOutlet weak var threeLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var nextButtonBot: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    var viewIndex = 0
    @IBAction func nextButton(sender: UIButton) {
              // print (phoneNumber)
       
        if (viewIndex == 0){
            let lower : UInt32 = 10000
            let upper : UInt32 = 99999
            
            code = String(arc4random_uniform(upper - lower) + lower)
            print (code)
            fireMessage()
            self.PageView!.scrollToNextViewController()
        }
        else if (viewIndex == 1){
            let greatID = CKRecordID(recordName: phoneNumber)
            
            publicDB.fetchRecordWithID(greatID) { fetchedPlace, error in
       
            }
            self.PageView!.scrollToNextViewController()
 


        }
        else if (viewIndex == 2){
           // print ("hi")
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("camera") as! cameraView
            frontWindow?.rootViewController = vc
            
        }
        
        
    }
    override func viewDidLoad() {
        
           // print("start sending message")
            
            // Use your own details here

        panGesture?.enabled = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginView.moveNext(_:)), name:"move", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginView.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginView.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
       // contactsync()
        
    }
    func moveNext(notification: NSNotification){
    self.PageView!.scrollToNextViewController()
       /* dispatch_async(dispatch_get_main_queue()) {
            self.iCloudLogin({ (success) -> () in
                if success {
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("camera") as! cameraView
                    frontWindow?.rootViewController = vc
                    print ("success")
                } else {
                    ("error")
                    // TODO error handling
                }
            })
        }*/

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

    func fireMessage(){
        let twilioSID = "ACf729e40728e0066539061b719410d14e"
        let twilioSecret = "2a8412ba5e572dfc451d6e6afe9d8269"
        let fromNumber = "3105893655"
        let toNumber = phoneNumber
        let message = "Your code is \(code)"
        // Build the request
        let request = NSMutableURLRequest(URL: NSURL(string:"https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/SMS/Messages")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = "From=\(fromNumber)&To=\(toNumber)&Body=\(message)".dataUsingEncoding(NSUTF8StringEncoding)
        
        // Build the completion block and send the request
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
        }).resume()
    }
    func numberFormatter( mobileNumbers: NSString) -> NSString {
        var mobileNumber = mobileNumbers
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("(", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString(")", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("-", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("+", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString(".", withString: "")
     

        
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

    }
    
    func PageView(PageView: pageView,
        didUpdatePageIndex index: Int) {

        //print (index)
        viewIndex = index
            if(viewIndex == 1){
                twoLabel.textColor = UIColor.whiteColor()
                twoLabel.backgroundColor = UIColor.blackColor()
                twoLabel.layer.backgroundColor = UIColor.blackColor().CGColor
                goButton.hidden = true
            }
            else if (viewIndex == 2){
                threeLabel.textColor = UIColor.whiteColor()
                threeLabel.layer.backgroundColor = UIColor.blackColor().CGColor
                threeLabel.backgroundColor = UIColor.blackColor()
                goButton.hidden = true
            }
    }
    
}






