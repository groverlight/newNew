//
//  loginCode.swift
//  TypeFace
//
//  Created by Aaron Liu on 2/11/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit
import CloudKit

class loginCode: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var codeDigit1: UILabel!
    @IBOutlet weak var codeDigit2: UILabel!
    @IBOutlet weak var codeDigit3: UILabel!
    @IBOutlet weak var codeDigit4: UILabel!
    @IBOutlet weak var codeDigit5: UILabel!
    var labelCounter = 0
    override func viewDidLoad() {
       // super.viewDidLoad()

            self.codeTextField.delegate = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginCode.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginCode.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
    }
    override func viewWillAppear(animated: Bool) {
  
        //codeTextField.becomeFirstResponder()
    }
    override func viewDidAppear(animated: Bool) {
        codeTextField.performSelector(#selector(UIResponder.becomeFirstResponder), withObject: nil, afterDelay: 0)
        labelCounter = 0
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //print ("\(textField.text!)\(string)")
        var newDigit:UILabel!

        if (range.length == 0){
            //print ("morechar")
            labelCounter += 1
        }
        switch labelCounter{
        case 1 :
             newDigit = codeDigit1
            break
        case 2 :
             newDigit = codeDigit2
            break
        case 3 :
             newDigit = codeDigit3
            break
        case 4 :
             newDigit = codeDigit4
            break
        case 5 :
             newDigit = codeDigit5
            break
        default:
            return false
        }
        if (range.length == 0){
            newDigit.text = string
        }
        else if (range.length == 1){
            //print ("lesschar")
            newDigit.text = ""
            labelCounter -= 1
        }
       // print (newDigit)
        if (labelCounter == 5){
            codeDigit5.text = string
            if ( code == textField.text! + string){
               // NSNotificationCenter.defaultCenter().postNotificationName("move", object: nil)
                
                //self.dismissViewControllerAnimated(true, completion: nil)
                let delay = 1 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue()) {
                let prefs = NSUserDefaults.standardUserDefaults()
                prefs.setValue("didLogin", forKey: "Login")
                self.performSegueWithIdentifier("goCamera", sender: self)



                    }
            }
            else {
                let wrongCode = UIAlertController(title: "Wrong Code Bruh", message: "Looks like the verification code was incorrect. Please Try Again.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                    NSNotificationCenter.defaultCenter().postNotificationName("move", object: nil)
                })
                wrongCode.addAction(okAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.codeTextField.text = ""
                    self.codeDigit1.text = ""
                    self.codeDigit2.text = ""
                    self.codeDigit3.text = ""
                    self.codeDigit4.text = ""
                    self.codeDigit5.text = ""
                    self.presentViewController(wrongCode, animated: true, completion: nil)
                }
            }
        
        }

        
        return true
    }
    

    func keyboardWillShow(notification: NSNotification) {
       // print ("keyboardwillshow")
        
        
    }
    func keyboardWillHide (notification: NSNotification) {
         //print ("keyboardwillhide")
   
    }
}
