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
import FBSDKShareKit
import FBSDKCoreKit
import FBSDKLoginKit
import Photos
import MobileCoreServices

class playerView: UIViewController,UIImagePickerControllerDelegate,FBSDKSharingDelegate,UINavigationControllerDelegate  , UIScrollViewDelegate, ASScreenRecorderDelegate,AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var header: UIView!
    //var imagePicker:UIImagePickerController
    @IBOutlet weak var facebookBut: UIButton!

    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var twitterBut: UIButton!

    
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var instagramBut: UIButton!
    
    @IBOutlet var backEmoji: UILabel!

    //var newButton:FBSDKShareButton = FBSDKShareButton()
    @IBAction func twitter(sender: AnyObject) {
        
        self.backButton.setTitle("another one", forState: .Normal)
        self.backButton.layer.cornerRadius = 6
        self.backEmoji.text = "👔"
        self.backEmoji.hidden = false
        
        let alertController = UIAlertController(title: "Twitter Video sharing", message: "Enter your tweet", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "#cakeTalk"
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let destinationPath = documentsPath.stringByAppendingPathComponent("movie.mov")
            let outputPath = NSURL(fileURLWithPath: destinationPath)
            let videoData = NSData(contentsOfURL: outputPath)
            // if (SocialVideoHelper.userHasAccessToTwitter()){
            let accountStore = ACAccountStore()
            let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            
            
            accountStore.requestAccessToAccountsWithType(accountType, options: nil) { granted, error in
                if (granted){
                    guard let tweetAcc = accountStore.accountsWithAccountType(accountType) where !tweetAcc.isEmpty else {
                        print("There are no Twitter accounts configured. You can add or create a Twitter account in Settings.")
                        return
                    }
                    let twitAccount = tweetAcc[0] as! ACAccount
                    print (twitAccount)
                    let textfield = alertController.textFields![0] as UITextField
                    SocialVideoHelper.uploadTwitterVideo(videoData,comment:textfield.text,account: twitAccount, withCompletion: nil)
                }
                else{
                    print (error)
                }
                
                
                
                
                
            }
            
        })
        
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        
    }
    
    @IBAction func instagram(sender: AnyObject) {
        self.backButton.setTitle("another one", forState: .Normal)
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
        self.backButton.setTitle("another one", forState: .Normal)
        let outputPath = NSURL.fileURLWithPath("\(NSTemporaryDirectory())animmovie.mp4")
        let objectsToShare = [outputPath]
        
        let activityViewController  = UIActivityViewController(activityItems:objectsToShare as [AnyObject], applicationActivities: nil)
        
        presentViewController(activityViewController, animated: true, completion: nil)
        
        
    }
    @IBOutlet weak var progressBar: UIView!
    
    
    
    @IBOutlet weak var labelView: UIView!
    @IBAction func backButtonAction(sender: AnyObject) {
        //self.performSegueWithIdentifier("segueToCamera", sender: self)
        arrayofText.removeAllObjects()
        do{
            let files = try self.fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
            for file:NSString in files!{
                try self.fileManager?.removeItemAtPath("\(NSTemporaryDirectory())\(file)")
            }
            
            
        }
        catch {
            // print("bad")
        }

        self.dismissViewControllerAnimated(false, completion: nil)
    }
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareBut: UIButton!
    var moviePlayer: AVPlayer?
    var numOfClips = 0
    var totalReceivedClips = 0
    var fileManager: NSFileManager? = NSFileManager()
    var labelFont: UIFont?
    var overlay: UIVisualEffectView?
    var didPlay = false
    var showStatusBar = false
    var toolTip: EasyTipView?
    var screenRecorder = ASScreenRecorder()
    var image:CGImageRef?
    var imageQueue:dispatch_queue_t?
    var capturedImage:CGImageRef?
    var needsNewImage = true
    var captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice?
    @IBAction func facebook(sender: AnyObject) {
        self.backButton.setTitle("another one", forState: .Normal)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let destinationPath = documentsPath.stringByAppendingPathComponent("movie.mov")
       let outputPath = NSURL(fileURLWithPath: destinationPath)

        let photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
        var videoAssetPlaceholder:PHObjectPlaceholder!
        photoLibrary.performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(outputPath)
            videoAssetPlaceholder = request!.placeholderForCreatedAsset
            },
                                    completionHandler: { success, error in
                                        if success {
                                            let localID = videoAssetPlaceholder.localIdentifier
                                            let assetID =
                                                localID.stringByReplacingOccurrencesOfString(
                                                    "/.*", withString: "",
                                                    options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
                                            let ext = "mov"
                                            let assetURLStr =
                                                "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
                                            let video : FBSDKShareVideo = FBSDKShareVideo()
                                            video.videoURL = NSURL(string:assetURLStr)
                                            let content : FBSDKShareVideoContent = FBSDKShareVideoContent()
                                            content.video = video
                                            
                                            // FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
                                            
                                            let dialog = FBSDKShareDialog()
                                            let newURL = NSURL(string: "fbauth2://")
                                            if (UIApplication.sharedApplication() .canOpenURL(newURL!)){
                                                print("native")
                                                dialog.mode = FBSDKShareDialogMode.ShareSheet
                                            }
                                            else{
                                                print("browser")
                                                dialog.mode = FBSDKShareDialogMode.Browser
                                            }
                                            
                                            dialog.shareContent = content;
                                            dialog.delegate = self;
                                            dialog.fromViewController = self;
                                            dialog.show()
                                            // Do something with assetURLStr
                                        }
        })
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
       
    }

    func setupVideo(index: Int){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerView.playerItemDidReachEnd(_:)), name:AVPlayerItemDidPlayToEndTimeNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerView.playerStartPlaying(_:)), name:UIApplicationDidBecomeActiveNotification, object: nil);
        
        let avAsset = AVAsset(URL: NSURL.fileURLWithPath("\(NSTemporaryDirectory())\(index).mp4"))
        print("index: \(index)")
        let avPlayerItem = AVPlayerItem(asset: avAsset)
        moviePlayer = AVPlayer(playerItem: avPlayerItem)
        let avLayer = AVPlayerLayer(player: moviePlayer)
        avLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        avLayer.frame = self.view.bounds
        self.movieView.layer.addSublayer(avLayer)
        self.moviePlayer?.play()
        let scrollLabel = PaddingLabel()
        scrollLabel.frame = CGRectMake(20,self.view.bounds.size.height*0.55, self.view.bounds.size.width*(2/3)-20,50)
        scrollLabel.textColor = UIColor.whiteColor()
        print (scrollLabel.frame)
        scrollLabel.font = labelFont
        scrollLabel.text = (arrayofText.objectAtIndex(index-1) as! String)
        print (scrollLabel.text)
        scrollLabel.numberOfLines = 0
        scrollLabel.sizeToFit()
        scrollLabel.layer.cornerRadius = 8
        scrollLabel.layer.masksToBounds = true
        //scrollLabel.alpha = 0.5
        scrollLabel.backgroundColor = randomColor(hue: .Random, luminosity: .Light)
        
        scrollLabel.setLineHeight(0)
        // scrollLabel.frame.origin.y = self.view.bounds.size.height/2-scrollLabel.bounds.size.height/2
        self.view.addSubview(scrollLabel)
        
        let animation: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)
        
        animation.duration = animationBeginTimes[index-1] + 4.25
        animation.repeatCount = 0
        animation.autoreverses = false
        //  animation.fromValue = scrollLabel.frame.origin.y
        animation.toValue = self.view.bounds.size.height/3 - scrollLabel.bounds.size.height
        animation.beginTime = AVCoreAnimationBeginTimeAtZero
        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
        
        
        let animation3 = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        animation3.toValue = NSValue(CGPoint: CGPointMake(1, 1))
        animation3.velocity = NSValue(CGPoint: CGPointMake(6, 6))
        animation3.springBounciness = 20.0
        animation3.beginTime = AVCoreAnimationBeginTimeAtZero
        animation3.repeatCount = 0
        animation3.autoreverses = false
        //animation3.removedOnCompletion = true
        // animation3.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
        let animation4 = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        animation4.duration = 0.00000001
        animation4.repeatCount = 0
        animation4.beginTime = AVCoreAnimationBeginTimeAtZero
        animation4.autoreverses = false
        animation4.fromValue = 0.0
        animation4.toValue = 1.0
        animation4.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
        
        // animation4.removedOnCompletion = true
        animation4.completionBlock = {(animation,finished) in
            let animation2: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
            animation2.duration = animationBeginTimes[index-1] + 4.25
            animation2.repeatCount = 0
            animation2.autoreverses = false
            animation2.toValue = 0
            animation2.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
            scrollLabel.layer.pop_addAnimation(animation2, forKey: "goDisappear")
        }
        
        scrollLabel.layer.pop_addAnimation(animation, forKey: "goUP")
        scrollLabel.layer.pop_addAnimation(animation3, forKey: "spring)")
        scrollLabel.layer.pop_addAnimation(animation4, forKey: "goAppear)")
        
        numOfClips -= 1
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.layer.cornerRadius = 6
        screenRecorder.delegate = self
        imageQueue = dispatch_queue_create("CameraViewController.imageQueue", DISPATCH_QUEUE_SERIAL)
    
        screenRecorder.videoURL =  NSURL.fileURLWithPath("\(NSTemporaryDirectory())animmovie.mp4")
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Unspecified) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
       
        
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice)
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA) ]
            output.setSampleBufferDelegate(self, queue:imageQueue!)
            captureSession.addOutput(output)
            captureSession.addInput(input)
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.view.layer.addSublayer(previewLayer)
            captureSession.startRunning()

        }
        catch{
            
        }
        
     
    }
    override func viewWillAppear(animated: Bool) {
        self.view.bringSubviewToFront(labelView)
        //let vc = MFMessageComposeViewControlle
        

        // let vc = SLComposeViewController(forServiceType: SLSer)
        // super.viewDidLoad()
        do{
            let String = "MediaCache"
            try self.fileManager?.removeItemAtPath("\(NSTemporaryDirectory())\(String)")        }
        catch{
            print("no media cache")
        }
        do{
            let files = try self.fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
            print (files)
            numOfClips = arrayofText.count
            totalReceivedClips = numOfClips
            print (numOfClips) // last where I Started
            //print (files)
        }
        catch {
            print("bad")
        }
        
        facebookBut.hidden = true
        twitterBut.hidden = true
        instagramBut.hidden = true
        shareBut.hidden = true
        // progressBarView.hidden = true
        backButton.hidden = true
        
        
        iPhoneScreenSizes()
        if (didPlay == false){
            self.moviePlayer?.seekToTime(kCMTimeZero)
            self.moviePlayer?.volume = 0.0
            self.moviePlayer?.actionAtItemEnd = AVPlayerActionAtItemEnd.None
            screenRecorder.startRecording()
            self.setupVideo(1)
            
        }
        var duration: CFTimeInterval = 0
        
        
        for i in 0..<arrayofText.count{
            let avAsset = AVAsset(URL: NSURL.fileURLWithPath("\(NSTemporaryDirectory())\(i+1).mov"))
            duration = duration + CMTimeGetSeconds(avAsset.duration)
        }
        
        self.progressBar.transform = CGAffineTransformMakeScale(1, 1)
        if (didPlay == false){
            
            
            
            
            
            self.progressBarView.hidden = false
            self.view.bringSubviewToFront(self.header)
            self.view.bringSubviewToFront(self.progressBarView)
            
            print (duration)
            UIView.animateWithDuration(duration) { () -> Void in
                self.progressBar.transform = CGAffineTransformMakeScale(0.000001, 1)
            }
        }
    }
    override func viewDidAppear(animated: Bool) {
        // exportVideo()
    }
    override func prefersStatusBarHidden() -> Bool {
        if showStatusBar {
            return false
        }
        return true
    }
    
    private func showStatusBar(enabled: Bool) {
        showStatusBar = enabled
        self.setNeedsStatusBarAppearanceUpdate()
        //prefersStatusBarHidden()
    }
    func playerItemDidReachEnd(notification: NSNotification){

        print ("item reached end \(numOfClips)")
        // moviePlayer.removeObserver(self, forKeyPath: "contentSize")
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        if (numOfClips > 0){
            // print ("(totalreceivedclips\(totalReceivedClips)")
            print ("(numfoclips\(numOfClips)")
            let clipsLeft = totalReceivedClips - numOfClips + 1
            // print ("clipsLeft\(clipsLeft)")
            setupVideo(clipsLeft)
        }
        else{
            
            

            
            screenRecorder.stopRecordingWithCompletion({
                self.captureSession.stopRunning()
                print("done")
            })
            overlay = UIVisualEffectView()
            let blurEffect = UIBlurEffect(style: .Dark)
            let overlayScrollView = UIScrollView(frame: CGRectMake(20,40+self.header.bounds.size.height,self.view.bounds.size.width-20,2*self.view.bounds.height/3))
            // print (overlayScrollView.frame)
            overlayScrollView.showsVerticalScrollIndicator = true
            overlayScrollView.indicatorStyle = UIScrollViewIndicatorStyle.White
            overlayScrollView.userInteractionEnabled = true
            overlayScrollView.scrollEnabled = true
            overlayScrollView.delegate = self
            
            var scrollHeightOverlay:CGFloat = 0.0
            //  let newLabel = UILabel(frame: CGRectMake(0, scrollView.bounds.size.height + scrollHeight, scrollView.bounds.size.width, textHeight! ))
            let arrayofBorders = NSMutableArray()
            for text in arrayofText{
                
                
                let newerLabel = UILabel(frame: CGRectMake(6, scrollHeightOverlay, self.view.bounds.size.width*(2/3)-20, 25))
                newerLabel.font =  UIFont(name:"RionaSans-Bold", size: 20.0)
                newerLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
                newerLabel.text = text as? String
                newerLabel.numberOfLines = 0
                newerLabel.sizeToFit()
                overlayScrollView.addSubview(newerLabel)
                
                let border = CALayer()
                border.frame = CGRectMake(0 , scrollHeightOverlay + 45 + self.header.bounds.size.height, 4, CGRectGetHeight(newerLabel.frame)-12)
                border.backgroundColor = UIColor(red: 85/255, green: 172/255, blue: 238/255, alpha: 1.0).CGColor

                arrayofBorders.addObject(border)
                //overlay!.layer.addSublayer(border)
                scrollHeightOverlay = scrollHeightOverlay + newerLabel.bounds.size.height + 10
                
            }
            overlayScrollView.contentSize = CGSizeMake(self.view.bounds.size.width-20,scrollHeightOverlay)
            let timeStampLabel = UILabel(frame: CGRectMake(6, overlayScrollView.contentSize.height , self.view.bounds.size.width*(2/3)-20,25))
            timeStampLabel.font = UIFont(name:"RionaSans-Bold", size: 10.0)
            timeStampLabel.textColor = UIColor.whiteColor() .colorWithAlphaComponent(0.4)
            timeStampLabel.text = "now"
            timeStampLabel.numberOfLines = 0
            timeStampLabel.sizeToFit()
            overlayScrollView.addSubview(timeStampLabel)
            let emojiLabel = UILabel(frame: CGRectMake(6, overlayScrollView.contentSize.height+16, self.view.bounds.size.width*(2/3)-20,25))
            emojiLabel.font = UIFont(name:"Avenir Next", size:14)
            emojiLabel.textColor = UIColor.whiteColor()
            emojiLabel.text = "👁"
            emojiLabel.numberOfLines = 0
            timeStampLabel.sizeToFit()
            overlayScrollView.addSubview(emojiLabel)
            showStatusBar(true)
            
            //let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
            // Put it somewhere, give it a frame...
            overlay!.frame = self.view.bounds
            self.view.addSubview(overlay!)
            UIView.animateWithDuration(1.5, animations: {self.overlay!.effect = blurEffect}, completion: { finished in
                self.header.backgroundColor = UIColor(red: 85/255, green: 172/255, blue: 238/255, alpha: 1.0)
                self.headerLabel.text = "share"
                let line = UIView(frame: CGRectMake(20,(self.facebookBut.frame.origin.y)-23, (self.view.bounds.size.width)-40, 0.5))
                line.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.30)
                self.view.addSubview(line)
                for border in arrayofBorders{
                    self.overlay!.layer.addSublayer(border as! CALayer)
                }
                self.view.addSubview(overlayScrollView)
                self.view.bringSubviewToFront(overlayScrollView)
                self.view.bringSubviewToFront(self.backButton)
                self.view.bringSubviewToFront(self.facebookBut)
                self.view.bringSubviewToFront(self.twitterBut)
                self.view.bringSubviewToFront(self.instagramBut)
                self.view.bringSubviewToFront(self.shareBut)
                self.view.bringSubviewToFront(self.header)
                self.view.bringSubviewToFront(line)
                self.facebookBut.hidden = false
                self.twitterBut.hidden = false
                self.instagramBut.hidden = false
                self.shareBut.hidden = false
                self.backButton.hidden = false
                self.backButton.transform = CGAffineTransformMakeScale(1.5, 1.5)
                UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                    self.backButton.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: { finished in
                        self.toolTip?.dismiss()
                        
                        var preferences = EasyTipView.Preferences()
                        preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
                        preferences.drawing.foregroundColor = UIColor.whiteColor()
                        preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
                        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.Bottom
                        self.toolTip = EasyTipView(text: "share with followers", preferences: preferences, delegate: nil)
                        self.toolTip!.show(forView: line,
                            withinSuperview: self.view)

                        
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
            labelFont = UIFont(name: "RionaSans-Bold", size: 24)
        case 568.0:
            //print("iPhone 5")
            labelFont = UIFont(name: "RionaSans-Bold", size: 24)
        case 667.0:
            //print("iPhone 6")
            labelFont = UIFont(name: "RionaSans-Bold", size: 28.5)
        case 736.0:
            //print("iPhone 6+")
            labelFont = UIFont(name: "RionaSans-Bold", size: 22 )
        default:
            break
            //print("not an iPhone")
            
        }


    }
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject: AnyObject]) {
        print(results)
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print("sharer NSError")
        print(error.description)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        print("sharerDidCancel")
    }
    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        print ("captuing output...")
        dispatch_sync(imageQueue!){
            if (self.needsNewImage == true){
                self.needsNewImage = false
                let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
                let cImage = CIImage(CVImageBuffer: pixelBuffer!)
                let context = CIContext()
                self.image = context.createCGImage(cImage, fromRect: self.view.bounds)
            }
        }
    }

    func writeBackgroundFrameInContext(contextRef: UnsafeMutablePointer<Unmanaged<CGContext>?>) {
        print ("writing frame...")
        dispatch_sync(imageQueue!){
            if ((self.image) != nil){
                let reference:CGContext = (contextRef.memory?.takeRetainedValue())!
                CGContextSaveGState(reference)
                CGContextDrawImage(reference, self.view.bounds, self.image)
                CGContextRestoreGState(reference)
                self.needsNewImage = true
            }
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
