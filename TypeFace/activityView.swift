
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
        print ("wild activityview will appear")


        if (userFull != nil){
                    activityTable.reloadData()
            /*let publicDB = CKContainer.defaultContainer().publicCloudDatabase
            let searchTerm = String(userFull!.phoneNumber!.characters.suffix(10))
            print (searchTerm)
            let predicate = NSPredicate(format: "toUser = '\(searchTerm)'")
            let query = CKQuery(recordType: "Message", predicate: predicate)
            
            publicDB.performQuery(query, inZoneWithID:  nil) { results, error in
                // ...
                if (error == nil){
                //print ("RESULTS\(results)")
                for result in results!{
                    print (result)
                    
                    self.activityTable.reloadData()
                    
                    let videos = result["videos"] as? Array<CKAsset>
                    for video in videos!{
                                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerItemDidReachEnd:"), name:AVPlayerItemDidPlayToEndTimeNotification, object: nil);
                        print (video)
                        dispatch_async(dispatch_get_main_queue()) {
                        let assetURL = video.fileURL as NSURL!
                        let videoData = NSData(contentsOfURL: assetURL!) 
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                        let destinationPath = documentsPath.stringByAppendingPathComponent("filename.MOV")
                        NSFileManager.defaultManager().createFileAtPath(destinationPath,contents:videoData, attributes:nil)
                        print(destinationPath)
                        let fileURL = NSURL(fileURLWithPath: destinationPath)
                        let avasset = AVAsset(URL: fileURL) as! AVURLAsset
                        print (avasset)
                        let playerItem = AVPlayerItem(asset: avasset)
                        print (playerItem)
                        let player = AVPlayer(playerItem: playerItem)
                        let avLayer = AVPlayerLayer(player: player)
                        avLayer.frame = self.view.bounds
                        avLayer.backgroundColor = UIColor.blackColor().CGColor
                        self.view.layer.addSublayer(avLayer)
                        player.seekToTime(kCMTimeZero)
                        player.play()
                
                        
                        print (avasset.duration)
                        }
                    
                    }
                    //let array = result["videos"]
                    //print (array)
                    
                        
                    
                    }
                

                }
                else{
                    print (error)
                }
        
            }*/
        }
    }
    func playerItemDidReachEnd(notification: NSNotification){
        print ("video ended")
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print ("making cell")
        //print (messages)
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let record:CKRecord = messages[indexPath.row]
        cell.textLabel!.text = record["name"] as? String
        //print (record)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            print (indexPath)
        frontWindow?.hidden = true
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("playerView2") as! playerView2
        print ("mesesage\(messages)")
        message = messages[indexPath.row]
        self.presentViewController(vc, animated: false, completion: { () -> Void in
           
        })
    }
    
   
}

extension String {
    
    func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.stringByAppendingPathComponent(path)
    }
}