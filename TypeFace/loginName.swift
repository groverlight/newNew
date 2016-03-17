//
//  loginName.swift
//  TypeFace
//
//  Created by Aaron Liu on 2/11/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit


class loginName: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var LowerTextField: UITextField!
    @IBOutlet weak var UpperTextField: UITextField!
    override func viewDidLoad() {
        UpperTextField.delegate = self
        //UpperTextField.becomeFirstResponder()
        UpperTextField.addTarget(self, action:Selector("UpperTextSelect"), forControlEvents: UIControlEvents.TouchUpInside)
        LowerTextField.addTarget(self, action:Selector("LowerTextSelect"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    override func viewDidAppear(animated: Bool) {
        UpperTextField.performSelector(Selector("becomeFirstResponder"), withObject: nil, afterDelay: 0)
        
    }
    override func viewWillDisappear(animated: Bool) {
      //  LowerTextField.resignFirstResponder()
        
        self.view.endEditing(true)
    }
    func UpperTextSelect(){
        if (LowerTextField.isFirstResponder()){
            LowerTextField.resignFirstResponder()
        }
        UpperTextField.becomeFirstResponder()
    }
    func LowerTextSelect(){
        if (UpperTextField.isFirstResponder()){
            UpperTextField.resignFirstResponder()
        }
        LowerTextField.becomeFirstResponder()
    }
}
