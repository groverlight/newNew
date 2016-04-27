//
//  loginPhone.swift
//  TypeFace
//
//  Created by Aaron Liu on 2/11/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit
import CoreTelephony

class loginPhone: UIViewController{

    
    @IBAction func termsofUse(sender: AnyObject) {
    }
    
    @IBOutlet weak var termsView: UILabel!
    
    
    @IBOutlet weak var termsBottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginCode.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginCode.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
  
    }
    override func viewDidAppear(animated: Bool) {
        //self.phoneTextField.delegate = self
        //self.phoneTextField.performSelector(#selector(UIResponder.becomeFirstResponder), withObject: nil, afterDelay: 0)

    }
 
    
    override func viewWillDisappear(animated: Bool) {
        print ("disappearing")
        //phoneTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // print ("keyboardwillshow")
        updateBottomLayoutConstraintWithNotification(notification)
        
    }
    func keyboardWillHide (notification: NSNotification) {
        //print ("keyboardwillhide")
        updateBottomLayoutConstraintWithNotification(notification)
        
    }
    func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
        //print ("updating bottom layout")
        let userInfo = notification.userInfo!
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let convertedKeyboardEndFrame = view.convertRect(keyboardEndFrame, fromView: view.window)
        //print (CGRectGetMaxY(self.view.bounds))
        //print(CGRectGetMinY(convertedKeyboardEndFrame))

        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            
            self.termsBottomConstraint.constant = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame) + 40

            
            print (self.termsBottomConstraint.constant)
        }
        
    }

}
