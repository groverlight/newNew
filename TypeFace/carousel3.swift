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
        UIApplication.sharedApplication().delegate?.window!?.rootViewController = vc
    }

}
