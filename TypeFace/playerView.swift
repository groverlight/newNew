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
import Social
import Accounts
import MessageUI

class playerView: UIViewController {
    
    
    
    
    @IBOutlet weak var facebookBut: UIButton!
    
    
    @IBOutlet weak var twitterBut: UIButton!
    
    
    @IBOutlet weak var instagramBut: UIButton!
    
    @IBOutlet weak var shareBut: UIButton!
    @IBAction func facebook(sender: AnyObject) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let destinationPath = documentsPath.stringByAppendingPathComponent("movie.mov")
        let outputPath = NSURL(fileURLWithPath: destinationPath)
        let videoData = NSData(contentsOfURL: outputPath)
        if (SocialVideoHelper.userHasAccessToFacebook()){
            let accountStore = ACAccountStore()
            let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
            let options:[String:String] = [
                "ACFacebookAppIdKey" : "123456789",
                "ACFacebookPermissionsKey" : "publish_stream",
                "ACFacebookAudienceKey" : ACFacebookAudienceEveryone]

            accountStore.requestAccessToAccountsWithType(accountType, options: options) { granted, error in
                if (granted){
                    guard let fbAcc = accountStore.accountsWithAccountType(accountType) where !fbAcc.isEmpty else {
                        print("There are no FB accounts configured. You can add or create a FB account in Settings.")
                        return
                    }
                    let FacebookAccount = fbAcc[0] as! ACAccount
                    SocialVideoHelper.uploadFacebookVideo(videoData,comment: "",account: FacebookAccount, withCompletion: nil)
                }
                else{
                    print (error)
                }
                
                
 
                

            }
            
        }
    }

    @IBAction func twitter(sender: AnyObject) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let destinationPath = documentsPath.stringByAppendingPathComponent("movie.mov")
        let outputPath = NSURL(fileURLWithPath: destinationPath)
        let videoData = NSData(contentsOfURL: outputPath)
        if (SocialVideoHelper.userHasAccessToTwitter()){
            let accountStore = ACAccountStore()
            let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)

            
            accountStore.requestAccessToAccountsWithType(accountType, options: nil) { granted, error in
                if (granted){
                    guard let tweetAcc = accountStore.accountsWithAccountType(accountType) where !tweetAcc.isEmpty else {
                        print("There are no Twitter accounts configured. You can add or create a Twitter account in Settings.")
                        return
                    }
                    let twitAccount = tweetAcc[0] as! ACAccount
                    SocialVideoHelper.uploadTwitterVideo(videoData,comment: "",account: twitAccount, withCompletion: nil)
                }
                else{
                    print (error)
                }
                
                
                
                
                
            }
            
        }
    }
    
    @IBAction func instagram(sender: AnyObject) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let destinationPath = documentsPath.stringByAppendingPathComponent("movie.mov")
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(destinationPath)) {
            
            UISaveVideoAtPathToSavedPhotosAlbum(destinationPath, self,#selector(playerView.video(_:didFinishSavingWithError:contextInfo:)),nil)
        
            
            
        }
    }
    func video(video: NSString, didFinishSavingWithError error:NSError, contextInfo:UnsafeMutablePointer<Void>){
        print("saved")
        let instagramURL = NSURL(string:  "instagram://library?AssetPath=\(video)" )
       // if(UIApplication.sharedApplication().canOpenURL(instagramURL!)){
            UIApplication.sharedApplication().openURL(instagramURL!)
        //}

    }
    
    @IBAction func share(sender: AnyObject) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let destinationPath = documentsPath.stringByAppendingPathComponent("movie.mov")
        let outputPath = NSURL(fileURLWithPath: destinationPath)
        let objectsToShare = [outputPath]

        let activityViewController  = UIActivityViewController(activityItems:objectsToShare as [AnyObject], applicationActivities: nil)
        
        presentViewController(activityViewController, animated: true, completion: nil)


    }
    @IBOutlet weak var progressBar: UIView!
    var moviePlayer: AVPlayer?
    var numOfClips = 0
    var totalReceivedClips = 0
    var fileManager: NSFileManager? = NSFileManager()
    var labelFont: UIFont?
    
    @IBOutlet weak var labelView: UIView!
    @IBAction func backButtonAction(sender: AnyObject) {
        //self.performSegueWithIdentifier("segueToCamera", sender: self)
        arrayofText.removeAllObjects()
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    @IBOutlet weak var backButton: UIButton!
    override func viewDidLoad() {
        //let vc = MFMessageComposeViewControlle

       // let vc = SLComposeViewController(forServiceType: SLSer)
        super.viewDidLoad()
        facebookBut.hidden = true
        twitterBut.hidden = true
        instagramBut.hidden = true
        shareBut.hidden = true
        progressBar.hidden = true
        backButton.hidden = true
        self.moviePlayer?.seekToTime(kCMTimeZero)
        self.moviePlayer?.volume = 0.0
        self.moviePlayer?.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        iPhoneScreenSizes()
    }
    func setupVideo(index: Int){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerView.playerItemDidReachEnd(_:)), name:AVPlayerItemDidPlayToEndTimeNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerView.playerStartPlaying(_:)), name:UIApplicationDidBecomeActiveNotification, object: nil);
        
        let avAsset = AVAsset(URL: NSURL.fileURLWithPath("\(NSTemporaryDirectory())\(index).mov"))
        // print("duration\(avAsset.duration)")
        let avPlayerItem = AVPlayerItem(asset: avAsset)
        moviePlayer = AVPlayer(playerItem: avPlayerItem)
        let avLayer = AVPlayerLayer(player: moviePlayer)
        avLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        avLayer.frame = self.view.bounds
        self.view.layer.addSublayer(avLayer)
        self.moviePlayer?.play()
        let scrollLabel = PaddingLabel()
        scrollLabel.frame = CGRectMake(20,self.view.bounds.size.height*0.55, self.view.bounds.size.width*(2/3)-20,50)
        scrollLabel.textColor = UIColor.whiteColor()
        
        scrollLabel.font = labelFont
        scrollLabel.text = (arrayofText.objectAtIndex(index-1) as! String)
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

    override func viewDidAppear(animated: Bool) {
        print ("videw did appear")
        var duration: CFTimeInterval = 0
        do{
            let files = try self.fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
          //  let String = "MediaCache"

            //try self.fileManager?.removeItemAtPath("\(NSTemporaryDirectory())\(String)")
            print (files)   
            numOfClips = (files?.count)!
            totalReceivedClips = numOfClips
            //print (numOfClips) // last where I Started
            print (files)
        }
        catch {
            print("bad")
        }
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let destinationPath = documentsPath.stringByAppendingPathComponent("movie.mov")
        let outputPath = NSURL(fileURLWithPath: destinationPath)
        let asset = AVURLAsset(URL: outputPath)
        duration = CMTimeGetSeconds(asset.duration)

        
        self.progressBar.transform = CGAffineTransformMakeTranslation(-self.view.bounds.size.width, 0)
        self.progressBar.hidden = false
        UIView.animateWithDuration(duration) { () -> Void in
             self.progressBar.transform = CGAffineTransformMakeTranslation(0, 0)
        }
        setupVideo(1)
    
    
    }
    
    func playerItemDidReachEnd(notification: NSNotification){
        //print ("item reached end \(numOfClips)")
       // moviePlayer.removeObserver(self, forKeyPath: "contentSize")
        NSNotificationCenter.defaultCenter().removeObserver(self)
      
        if (numOfClips > 0){
           // print ("(totalreceivedclips\(totalReceivedClips)")
            //print ("(numfoclips\(numOfClips)")
            let clipsLeft = totalReceivedClips - numOfClips + 1
           // print ("clipsLeft\(clipsLeft)")
            setupVideo(clipsLeft)
        }
        else{
            //print ("done with video clips")
            do{
                let files = try self.fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
                for file:NSString in files!{
                    try self.fileManager?.removeItemAtPath("\(NSTemporaryDirectory())\(file)")
                }
                
                
            }
            catch {
                // print("bad")
            }
            
            let overlay = UIVisualEffectView()
            let blurEffect = UIBlurEffect(style: .Dark)
            //let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
            // Put it somewhere, give it a frame...
            overlay.frame = self.view.bounds
            self.view.addSubview(overlay)
            UIView.animateWithDuration(1.5, animations: {overlay.effect = blurEffect}, completion: { finished in
             
                        self.view.bringSubviewToFront(self.backButton)
                        self.view.bringSubviewToFront(self.facebookBut)
                        self.view.bringSubviewToFront(self.twitterBut)
                        self.view.bringSubviewToFront(self.instagramBut)
                        self.view.bringSubviewToFront(self.shareBut)
                        //self.facebookBut.hidden = false
                        //self.twitterBut.hidden = false
                        //self.instagramBut.hidden = false
                        //self.shareBut.hidden = false
                        self.backButton.hidden = false
                        self.backButton.transform = CGAffineTransformMakeScale(1.5, 1.5)
                        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                            self.backButton.transform = CGAffineTransformMakeScale(1, 1)
                            }, completion: { finished in
                               
                        })

                
                
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
            //print("iPhone 3,4")
            labelFont = UIFont(name: "AvenirNext-Medium", size: 24)
        case 568.0:
            //print("iPhone 5")
            labelFont = UIFont(name: "AvenirNext-Medium", size: 24)
        case 667.0:
            //print("iPhone 6")
            labelFont = UIFont(name: "AvenirNext-Medium", size: 28.5)
        case 736.0:
            //print("iPhone 6+")
            labelFont = UIFont(name: "AvenirNext-Medium", size: 32 )
        default:
            break
            //print("not an iPhone")
            
        }


    }

}

extension UILabel {
    
    func setLineHeight(lineHeight: CGFloat) {
        let text = self.text
        if let text = text {
            let attributeString = NSMutableAttributedString(string: text)
            let style = NSMutableParagraphStyle()
            style.lineHeightMultiple = 0.9
            style.lineSpacing = lineHeight
            attributeString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, text.characters.count))
            self.attributedText = attributeString
        }
    }
}
