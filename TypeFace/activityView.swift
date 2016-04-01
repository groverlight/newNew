
//
//  activityView.swift
//  TypeFace
//
//  Created by Aaron Liu on 2/10/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//

import UIKit
import CloudKit
import AVFoundation
import AVKit
import Foundation
var friends : [NSDictionary] = []
var activities : [NSDictionary] = []
var messages : [CKRecord] = []
var message:CKRecord?

class activityView: UIViewController,UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var activityTable: UITableView!
    @IBOutlet weak var noFriendsView: UIView!
    var numOfClips = 0
    var totalReceivedClips = 0
    var fileManager: NSFileManager? = NSFileManager()
    var labelFont: UIFont?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
       // print ("activity did load")
        activityTable.delegate = self
        activityTable.dataSource = self
        if (activities.count == 0)
        {
            //noFriendsView.hidden = false
        }
       
    }
    override func viewDidAppear(animated: Bool) {
       // print ("wild activityview will appear")

        activityTable.reloadData()

    }
    func playerItemDidReachEnd(notification: NSNotification){
        print ("video ended")
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recentMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print ("making cell")
        //print (messages)
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let dictionary:[String:AnyObject] = recentMessages[indexPath.row]
        print (dictionary)
        cell.textLabel!.text = dictionary["fullName"] as? String
        //print (record)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            print (indexPath)
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("playerView2") as! playerView2
        print ("message\(messages)")
        let tempDict:[String:AnyObject] = recentMessages[indexPath.row]
        for eachMessage in messages{
            if (eachMessage["phone"] as! String == tempDict["phone"] as! String){
                message = eachMessage
                frontWindow?.hidden = true
                self.dismissViewControllerAnimated(false, completion: nil)
                self.presentViewController(vc, animated: false, completion: { () -> Void in
                    
                })
            }
        }
       // message = messages[indexPath.row]

    }
    
   
}

extension String {
    
    func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.stringByAppendingPathComponent(path)
    }
}