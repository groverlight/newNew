//
//  loginName.swift
//  TypeFace
//
//  Created by Aaron Liu on 2/11/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit


class loginName: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var iCloudButton: UIButton!
    
    @IBAction func iCloudAction(sender: AnyObject) {
        self.iCloudLogin({ (success) -> () in
            if success {
               
                dispatch_async(dispatch_get_main_queue()) {
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("camera") as! cameraView
                    frontWindow?.rootViewController = vc
                    let blur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
                    let blurView = UIVisualEffectView(effect: blur)
                    blurView.frame = UIScreen.mainScreen().bounds
                    
                    frontWindow?.insertSubview(blurView, atIndex: 0)

                }
               // print ("success")
            } else {
                ("error")
                // TODO error handling
            }
        })
    }
    private func iCloudLogin(completionHandler: (success: Bool) -> ()) {
        cloudManager.requestPermission { (granted) -> () in
            if !granted {
                let iCloudAlert = UIAlertController(title: "iCloud Error", message: "There was an error connecting to iCloud. Check iCloud settings by going to Settings > iCloud.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                    let url = NSURL(string: "prefs:root=CASTLE")
                    UIApplication.sharedApplication().openURL(url!)
                })
                
                iCloudAlert.addAction(okAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(iCloudAlert, animated: true, completion: nil)
                }
            } else {
                cloudManager.getUser({ (success, let user) -> () in
                    if success {
                        userFull = user
                        
                        cloudManager.getUserInfo(userFull!, completionHandler: { (success, user) -> () in
                            if success {
                                
                                completionHandler(success: true)
                            }
                        })
                    } else {
                        // TODO error handling
                    }
                })
            }
        }
    }
}
