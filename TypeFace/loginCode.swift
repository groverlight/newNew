//
//  loginCode.swift
//  TypeFace
//
//  Created by Aaron Liu on 2/11/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit


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

        if ( code == textField.text! + string){
                NSNotificationCenter.defaultCenter().postNotificationName("move", object: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
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
