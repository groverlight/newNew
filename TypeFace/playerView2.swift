//
//  playerView.swift
//  TypeFace
//
//  Created by Aaron Liu on 2/23/16.
//  Copyright © 2016 Aaron Liu. All rights reserved.
//
import AVFoundation
import AVKit
import UIKit
import GPUImage
import CloudKit
var recentMessages = Array<[String:AnyObject]>()
class playerView2: UIViewController {
    @IBOutlet weak var progressBar: UIView!
    var numOfClips = 0
    var totalReceivedClips = 0
    var fileManager: NSFileManager? = NSFileManager()
    var labelFont: UIFont?
    var arrayofMessageTxt: [String] = []
    var arrayofMessageVids: [AVAsset] = []
    @IBOutlet weak var labelView: UIView!
    @IBAction func backButtonAction(sender: AnyObject) {
        //self.performSegueWithIdentifier("segueToCamera", sender: self)
        
        self.dismissViewControllerAnimated(false, completion: {
            frontWindow?.hidden = false
        })
    }
    @IBOutlet weak var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //organizeMessages()
        
        progressBar.hidden = true
        iPhoneScreenSizes()
        arrayofMessageTxt = message!["text"] as! Array<String>
        print (arrayofMessageTxt)
        let videos = message!["videos"] as? Array<CKAsset>
        for video in videos!{
           // dispatch_async(dispatch_get_main_queue()) {
                let assetURL = video.fileURL as NSURL!
                let videoData = NSData(contentsOfURL: assetURL!)
                let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                let destinationPath = documentsPath.stringByAppendingPathComponent("filename.MOV")
                NSFileManager.defaultManager().createFileAtPath(destinationPath,contents:videoData, attributes:nil)
                print(destinationPath)
                let fileURL = NSURL(fileURLWithPath: destinationPath)
                let avasset = AVAsset(URL: fileURL) as! AVURLAsset
                self.arrayofMessageVids.append(avasset)

            //}
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        var duration: CFTimeInterval = 0
    
                   numOfClips = arrayofMessageTxt.count
                   totalReceivedClips = numOfClips//print (numOfClips) // last where I Started
    
            //print("bad")
        
        for i in 0 ..< numOfClips {
            let avAsset = arrayofMessageVids[i]
            duration = duration + CMTimeGetSeconds(avAsset.duration)
        }
        
        self.progressBar.transform = CGAffineTransformMakeTranslation(-self.view.bounds.size.width, 0)
        self.progressBar.hidden = false
        UIView.animateWithDuration(duration) { () -> Void in
            self.progressBar.transform = CGAffineTransformMakeTranslation(0, 0)
        }
        setupVideo(1)
    }
    func setupVideo(index: Int){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerView2.playerItemDidReachEnd(_:)), name:AVPlayerItemDidPlayToEndTimeNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerView2.playerStartPlaying(_:)), name:UIApplicationDidBecomeActiveNotification, object: nil);
        
        let avAsset = arrayofMessageVids[index-1]//AVAsset(URL: NSURL.fileURLWithPath("\(NSTemporaryDirectory())\(index).mov"))
        // print("duration\(avAsset.duration)")
        let avPlayerItem = AVPlayerItem(asset: avAsset)
        let moviePlayer = AVPlayer(playerItem: avPlayerItem)
        let avLayer = AVPlayerLayer(player: moviePlayer)
        avLayer.videoGravity = AVLayerVideoGravityResize
        avLayer.frame = self.view.bounds
        self.view.layer.addSublayer(avLayer)
        moviePlayer.seekToTime(kCMTimeZero)
        moviePlayer.play()
        let scrollLabel = PaddingLabel()
        scrollLabel.frame = CGRectMake(20,self.view.bounds.size.height*0.55, self.view.bounds.size.width*(2/3)-20,50)
        scrollLabel.textColor = UIColor.whiteColor()
        
        scrollLabel.font = labelFont
        scrollLabel.text = arrayofMessageTxt[index-1] 
        scrollLabel.numberOfLines = 0
        scrollLabel.sizeToFit()
        scrollLabel.layer.cornerRadius = 8
        scrollLabel.layer.masksToBounds = true
        //scrollLabel.alpha = 0.5
        scrollLabel.backgroundColor = randomColor(hue: .Random, luminosity: .Light)
        
        scrollLabel.setLineHeight(0)
        // scrollLabel.frame.origin.y = self.view.bounds.size.height/2-scrollLabel.bounds.size.height/2
        self.labelView.addSubview(scrollLabel)
        self.view.bringSubviewToFront(labelView)
        let labelSpring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        
        labelSpring.toValue = NSValue(CGPoint: CGPointMake(1, 1))
        labelSpring.velocity = NSValue(CGPoint: CGPointMake(6, 6))
        labelSpring.springBounciness = 20.0
        scrollLabel.pop_addAnimation(labelSpring, forKey: "spring")
        UIView.animateWithDuration(CMTimeGetSeconds(avAsset.duration) + 4.25, delay: 0, options: [UIViewAnimationOptions.CurveLinear], animations: { () -> Void in
            scrollLabel.frame.origin.y = self.view.bounds.size.height/3 - scrollLabel.bounds.size.height//scrollLabel.frame.origin.y - self.view.bounds.size.height * 0.5
            
            },completion: {(finished) -> Void in
                scrollLabel.removeFromSuperview()})
        UIView.animateWithDuration(CMTimeGetSeconds(avAsset.duration) + 4.25, delay: 0, options: [UIViewAnimationOptions.CurveEaseIn], animations: { () -> Void in
            scrollLabel.alpha = 0
            },completion: nil)
        
        
        
        
        numOfClips -= 1
    }
    
    func playerItemDidReachEnd(notification: NSNotification){
        //print ("item reached end \(numOfClips)")
        // moviePlayer.removeObserver(self, forKeyPath: "contentSize")
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        if (numOfClips > 0){
            let clipsLeft = totalReceivedClips - numOfClips + 1
            setupVideo(clipsLeft)
        }
        else{
            print ("done with video clips")
            do{
                let files = try self.fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
                for file:NSString in files!{
                    try self.fileManager?.removeItemAtPath("\(NSTemporaryDirectory())\(file)")
                }
                
                
            }
            catch {
                // print("bad")
            }
            let publicDB = CKContainer.defaultContainer().publicCloudDatabase
            publicDB.deleteRecordWithID((message?.recordID)!, completionHandler: {recordID, error in
                NSLog("OK or \(error)")
                })
            if let index = messages.indexOf(message!) {
                messages.removeAtIndex(index)
            }
            
            let overlay = UIVisualEffectView()
            let blurEffect = UIBlurEffect(style: .Dark)
            //let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
            // Put it somewhere, give it a frame...
            overlay.frame = self.view.bounds
            self.view.addSubview(overlay)
            UIView.animateWithDuration(1.5, animations: {overlay.effect = blurEffect}, completion: { finished in
                self.view.bringSubviewToFront(self.backButton)
                self.backButton.hidden = false
                self.backButton.transform = CGAffineTransformMakeScale(1.5, 1.5)
                UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                    self.backButton.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: nil)
                
                
                
            })
            
        }
        
    }
    
    func playerStartPlaying(notification: NSNotification){
        print ("player started playing")
    }
    func iPhoneScreenSizes(){
        let bounds = UIScreen.mainScreen().bounds
        let height = bounds.size.height
        
        switch height {
        case 480.0:
           // print("iPhone 3,4")
            labelFont = UIFont(name: "AvenirNext-Medium", size: 24)
        case 568.0:
            //print("iPhone 5")
            labelFont = UIFont(name: "AvenirNext-Medium", size: 24)
        case 667.0:
            //print("iPhone 6")
            labelFont = UIFont(name: "AvenirNext-Medium", size: 28.5)
        case 736.0:
            //print("iPhone 6+")
            labelFont = UIFont(name: "AvenirNext-Medium", size: 25 )
        default:
           // print("not an iPhone")
            break
        }
        
        
}

}
