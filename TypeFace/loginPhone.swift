//
//  loginPhone.swift
//  TypeFace
//
//  Created by Aaron Liu on 2/11/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit
import Parse
import Bolts

class loginPhone: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var phoneTextField: UITextField!

    
    @IBAction func countryCode(sender: AnyObject) {
    }
    override func viewDidLoad() {
        phoneTextField.delegate = self
        phoneTextField.becomeFirstResponder()
    }
    override func viewWillDisappear(animated: Bool) {
        phoneTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let length = getLength(textField.text!)
        //print (length)
        if (length == 10){
            if (range.length == 0){
                return false;
            }
        }
        if (length == 3) {
            let num = numberFormatter(textField.text!)
            textField.text = "(\(num))-"
            if (range.length > 0){
                textField.text = "\(num.substringToIndex(3))"
            }
        }
        else if (length == 6){
            let num = numberFormatter(textField.text!)
            textField.text = "(\(num.substringToIndex(3)))-\(num.substringFromIndex(3))-"
            if (range.length > 0){
                textField.text = "\(num.substringToIndex(3))-\(num.substringFromIndex(3)))"
            }
        }
        phoneNumber = numberFormatter(phoneTextField.text!)
        return true
    }
    
    func getLength(var mobileNumber:NSString) -> NSInteger {
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("(", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString(")", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("-", withString: "")
        mobileNumber = mobileNumber.stringByReplacingOccurrencesOfString("+", withString: "")
        let length = mobileNumber.length
        return length
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
