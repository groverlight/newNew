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


class playerView: UIViewController {
    var moviePlayer: AVPlayer?
    var numOfClips = 0
    var totalReceivedClips = 0
    var fileManager: NSFileManager? = NSFileManager()
    var labelFont: UIFont?
    @IBOutlet weak var labelView: UIView!
    @IBAction func backButtonAction(sender: AnyObject) {
        //self.performSegueWithIdentifier("segueToCamera", sender: self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBOutlet weak var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        /*let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let overlay = UIVisualEffectView(effect: blurEffect)
        // Put it somewhere, give it a frame...
        overlay.frame = self.view.bounds
        self.blurBackground.addSubview(overlay)
        self.blurBackground.alpha = 0*/
        backButton.hidden = true
        self.moviePlayer?.seekToTime(kCMTimeZero)
        self.moviePlayer?.volume = 0.0
        self.moviePlayer?.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        iPhoneScreenSizes()
    }
    
    override func viewDidAppear(animated: Bool) {
        do{
            let files = try fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
            numOfClips = (files?.count)!
            totalReceivedClips = numOfClips
            //print (numOfClips) // last where I Started
        }
        catch {
            print("bad")
        }
        setupVideo(1)
    }
    func setupVideo(index: Int){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerItemDidReachEnd:"), name:AVPlayerItemDidPlayToEndTimeNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerStartPlaying:"), name:UIApplicationDidBecomeActiveNotification, object: nil);

        let avAsset = AVAsset(URL: NSURL.fileURLWithPath("\(NSTemporaryDirectory())\(index).m4v"))
       // print("duration\(avAsset.duration)")
        let avPlayerItem = AVPlayerItem(asset: avAsset)
        moviePlayer = AVPlayer(playerItem: avPlayerItem)
        let avLayer = AVPlayerLayer(player: moviePlayer)
        avLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        avLayer.frame = self.view.bounds
        self.view.layer.addSublayer(avLayer)
        self.moviePlayer?.play()
        let scrollLabel = UILabel(frame: CGRectMake(0,2*self.view.bounds.size.height/3, self.view.bounds.size.width,50))
        scrollLabel.textColor = UIColor.whiteColor()
        scrollLabel.font = labelFont
        scrollLabel.text = (arrayofText.objectAtIndex(index-1) as! String)
        scrollLabel.numberOfLines = 0
        scrollLabel.sizeToFit()
        self.labelView.addSubview(scrollLabel)
        self.view.bringSubviewToFront(labelView)
       /* UIView.animateWithDuration(CMTimeGetSeconds(avAsset.duration)) { () -> Void in
            scrollLabel.frame.origin.y = self.view.bounds.size.height/4
        }*/
        let labelAnim = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)
        labelAnim.duration = CMTimeGetSeconds(avAsset.duration)
        labelAnim.toValue = self.view.bounds.size.height/4
        labelAnim.completionBlock = { (animation, finished) in
            if (finished){
                //print ("finished")
                UIView.animateWithDuration(1.25, animations: { () -> Void in
                    scrollLabel.alpha = 0
                    scrollLabel.frame.origin.y =  scrollLabel.frame.origin.y  - 100
                    }, completion: { (finished) -> Void in
                        scrollLabel.removeFromSuperview()
                })
               /* let labelCloseAlpha = POPBasicAnimation (propertyNamed: kPOPViewAlpha)
                labelCloseAlpha.toValue = 0
                labelCloseAlpha.duration = 1.25
                let labelCloseY = POPBasicAnimation (propertyNamed: kPOPLayerPositionY)
                labelCloseY.duration = 1.25
                labelCloseY.toValue = self.view.bounds.size.height/6
                scrollLabel.pop_addAnimation(labelCloseAlpha, forKey: "alpha")
                scrollLabel.pop_addAnimation(labelCloseY, forKey: "Y")*/
             }
            }
        scrollLabel.pop_addAnimation(labelAnim, forKey: "scrollUP")

                
                
        
          --numOfClips
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
                let files = try fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
                for file:NSString in files!{
                    try fileManager?.removeItemAtPath("\(NSTemporaryDirectory())\(file)")
                }
                print (files)
            }
            catch {
                print("bad")
            }
            arrayofText.removeAllObjects()
            //if you have more UIViews, use an insertS
            //self.dismissViewControllerAnimated(true, completion: nil)
            /*self.view.bringSubviewToFront(blurBackground)
            UIView.animateWithDuration(1.5, animations: {
                self.blurBackground.alpha = 0.9
            })*/
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

                       // self.backButton.layer
                
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
            print("iPhone 3,4")
             labelFont = UIFont(name: "AvenirNext-Medium", size: 28.5)
        case 568.0:
            print("iPhone 5")
             labelFont = UIFont(name: "AvenirNext-Medium", size: 28.5)
        case 667.0:
            print("iPhone 6")
             labelFont = UIFont(name: "AvenirNext-Medium", size: 33.5)
        case 736.0:
            print("iPhone 6+")
             labelFont = UIFont(name: "AvenirNext-Medium", size: 37 )
        default:
            print("not an iPhone")
            
        }
        
        
    }
}
