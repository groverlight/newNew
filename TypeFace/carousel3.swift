//
//  carousel3.swift
//  cakeTalk
//
//  Created by Aaron Liu on 4/12/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit

class carousel3: UIViewController {
    @IBOutlet weak var nextButt: UIButton!
   
    @IBAction func nextButtAct(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("login") as! loginView
        self.dismissViewControllerAnimated(true, completion: nil)
        dispatch_async(dispatch_get_main_queue()) {
            UIApplication.sharedApplication().delegate?.window!?.rootViewController = vc
        }
    }

}
