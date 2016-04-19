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

    override func viewDidLoad() {


  
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
    
   

}
