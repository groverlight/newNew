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

    @IBOutlet weak var scrollTextView: UITextView!
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
        
        //print ("index: \(index)")
        scrollTextView.text = arrayofText.objectAtIndex(index-1) as! String
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerItemDidReachEnd:"), name:AVPlayerItemDidPlayToEndTimeNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerStartPlaying:"), name:UIApplicationDidBecomeActiveNotification, object: nil);

        let avAsset = AVAsset(URL: NSURL.fileURLWithPath("\(NSTemporaryDirectory())\(index).m4v"))
        let avPlayerItem = AVPlayerItem(asset: avAsset)
        moviePlayer = AVPlayer(playerItem: avPlayerItem)
        let avLayer = AVPlayerLayer(player: moviePlayer)
        avLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        avLayer.frame = self.view.bounds
        self.view.layer.addSublayer(avLayer)
        self.moviePlayer?.play()
        self.view.bringSubviewToFront(scrollTextView)
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
                       // self.backButton.layer
                
                })

        }
        
    }
    
    func playerStartPlaying(notification: NSNotification){
        print ("player started playing")
    }
}
