//
//  cameraView.swift
//  
//
//  Created by Aaron Liu on 2/9/16.
//
//

import AVFoundation
import UIKit
import GPUImage
import CloudKit
/*

 let date = NSDate()
 let calendar = NSCalendar.currentCalendar()
 let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
 let hour = components.hour
 let minutes = components.minute
 @IBOutlet weak var toolTipPos: UIButton!
*/

var arrayofText: NSMutableArray = []
var dateArray: NSMutableArray = []
var animationBeginTimes:Array = [CFTimeInterval]()

class cameraView: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIScrollViewDelegate {
    var recording = false
    var shouldGoDown = false
    var previousRect = CGRectZero
    var oldKeyboardHeight:CGFloat = 0.0
    var autoCorrectHeight:CGFloat = 0.0
    var imagePicker: UIImagePickerController! = UIImagePickerController()
    var actualOffset:CGPoint = CGPoint()
    var typingButtonFrame : CGRect!
    var scrollCounter:CGFloat = 0.0
    var scrollHeightCounter = 0
    var oldLabel: UILabel?
    var scrollHeight:CGFloat = 0.0
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var shouldEdit = true
    var videoCamera:GPUImageVideoCamera?
    var filter:GPUImageMissEtikateFilter?
    var filteredImage: GPUImageView?
    var newImage: GPUImageView?
    var movieWriter: GPUImageMovieWriter?
    var movieComposition: GPUImageMovieComposition?
    var gradientView:GradientView = GradientView()
    var clipCount = 1
    var fileManager: NSFileManager? = NSFileManager()
    var longPressRecognizer: UILongPressGestureRecognizer!
    var showStatusBar = true
    var firstTime = false
    var toolTip:EasyTipView?
    @IBOutlet weak var header: UIView!
       @IBOutlet weak var cakeTalkLabel: UILabel!
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    @IBOutlet weak var weGoodEmoji: UILabel!
    @IBOutlet weak var clearAllEmoji: UILabel!
    @IBOutlet weak var progressBar: UIView!    
    @IBOutlet weak var animatedBar: UIView!
    @IBOutlet weak var characterCounter: UILabel!
    @IBOutlet weak var quitScrollView: UIButton!
    @IBOutlet weak var clearAllScroll: UIButton!
    @IBOutlet weak var bottomScrollView: NSLayoutConstraint!
    @IBAction func clearScrollAct(sender: AnyObject) {
        quitScrollView.hidden = true
        clearAllScroll.hidden = true
        toolTip?.dismiss()
        self.typingButton.userInteractionEnabled = true
        panGesture?.enabled = true
        longPressRecognizer.enabled = true
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        self.scrollHeight = 0
        for subview in self.scrollView.subviews {
            if subview is UILabel{
                subview.removeFromSuperview()
            }
        }
        clipCount = 1
        scrollCounter = 0
        do{
            let files = try fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
            for file:NSString in files!{
                try fileManager?.removeItemAtPath("\(NSTemporaryDirectory())\(file)")
            }

            
        }
        catch {
            print("bad")
        }
        self.cameraTextField.returnKeyType = UIReturnKeyType.Default
        self.weGoodEmoji.hidden = true
        self.clearAllEmoji.hidden = true
        arrayofText.removeAllObjects()
        animationBeginTimes.removeAll()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.header.backgroundColor = UIColor.blackColor()
            self.cakeTalkLabel.text = "caketalk"
            self.quitScrollView.transform = CGAffineTransformMakeTranslation(0, 2000)
            self.clearAllScroll.transform = CGAffineTransformMakeTranslation(0, 2000)
            }) { (finished) -> Void in
                self.quitScrollView.hidden = true
                self.clearAllScroll.hidden = true
                self.toolTip?.dismiss()
                var preferences = EasyTipView.Preferences()
                preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
                preferences.drawing.foregroundColor = UIColor.whiteColor()
                preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
                preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.Bottom
                self.toolTip = EasyTipView(text: "type: I like [something you like]", preferences: preferences, delegate: nil)
                self.toolTip!.show(forView: self.toolTipBut,
                              withinSuperview: self.view)

                for subview in self.view.subviews {
                    if subview is UIVisualEffectView {
                        subview.removeFromSuperview()
                    }
                }
                
               self.cameraTextField.becomeFirstResponder()
        }

    }
    @IBAction func quitScrollAct(sender: AnyObject){
      toolTip?.dismiss()
        self.typingButton.userInteractionEnabled = true
        panGesture?.enabled = true
        longPressRecognizer.enabled = true
        self.weGoodEmoji.hidden = true
        self.clearAllEmoji.hidden = true
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.header.backgroundColor = UIColor.blackColor()
            self.cakeTalkLabel.text = "caketalk"
            self.quitScrollView.transform = CGAffineTransformMakeTranslation(0, 2000)
            self.clearAllScroll.transform = CGAffineTransformMakeTranslation(0, 2000)
            }) { (finished) -> Void in
                self.quitScrollView.hidden = true
                self.clearAllScroll.hidden = true
                if (self.cameraTextField.text.characters.count == 0){
                    self.toolTip?.dismiss()
                    var preferences = EasyTipView.Preferences()
                    preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
                    preferences.drawing.foregroundColor = UIColor.whiteColor()
                    preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
                    preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.Bottom
                    self.toolTip = EasyTipView(text: "type: I like [something you like]", preferences: preferences, delegate: nil)
                   self.toolTip!.show(forView: self.toolTipBut,
                                  withinSuperview: self.view)

                }
                for subview in self.view.subviews {
                    if subview is UIVisualEffectView {
                        subview.removeFromSuperview()
      
                    }
                }
                
                self.cameraTextField.becomeFirstResponder()
        }
    }

    @IBOutlet weak var toolTipBut: UIButton!
    @IBOutlet weak var toolTipLayout: NSLayoutConstraint!
    @IBOutlet weak var characterCountBottom: NSLayoutConstraint!
    
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var emoji: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var typingButton: UIButton!
    @IBAction func typingButtonFunc(sender: AnyObject) {
        if (cameraTextField.text.characters.count == 0){

            typingButton.userInteractionEnabled = false
            emojiLabel.userInteractionEnabled = false
            characterCounter.userInteractionEnabled = false
            let buttonNo = POPSpringAnimation (propertyNamed: kPOPLayerPositionX)
            buttonNo.springBounciness = 20
            buttonNo.velocity = (1000)
            let buttonNo3 = POPSpringAnimation (propertyNamed: kPOPLayerPositionX)
            buttonNo3.springBounciness = 20
            buttonNo3.velocity = (1000)
            let buttonNo2 = POPSpringAnimation (propertyNamed: kPOPLayerPositionX)
            buttonNo2.springBounciness = 20
            buttonNo2.velocity = (1000)
            buttonNo.completionBlock = { (animation, finished) in
                if (finished){
                    self.typingButton.userInteractionEnabled = true
                }
            }
            buttonNo2.completionBlock = { (animation, finished) in
                if (finished){
                    self.emojiLabel.userInteractionEnabled = true
                    self.characterCounter.userInteractionEnabled = true
                }
            }
            emojiLabel.pop_addAnimation(buttonNo2, forKey: "shake2")
            characterCounter.pop_addAnimation(buttonNo3, forKey: "shake3")
            typingButton.pop_addAnimation(buttonNo, forKey: "shake")

            
        }
        else{
                self.toolTip?.hidden = true
                self.showStatusBar(false)
                self.header.alpha = 0.35
         
                
                
                
                self.longPressRecognizer.enabled = false
                self.cakeTalkLabel.hidden = true
                self.newImage = GPUImageView()
                self.newImage?.frame = self.view.bounds
                let newfilter = GPUImagePixellateFilter()
                //filter?.blurRadiusInPixels = 4
                self.videoCamera?.addTarget(newfilter)
                //print (filter)
                newfilter.addTarget(self.newImage)
                self.view.insertSubview(self.newImage!, aboveSubview:(self.filteredImage)!)
                self.typingButton.userInteractionEnabled = false
                self.cameraTextField.resignFirstResponder()
                //cameraTextField.
                panGesture?.enabled = false
                //print(self.cameraTextField.contentInset)
                let textHeight = self.cameraTextField.font?.lineHeight
                self.shouldGoDown = false
                if (self.oldLabel?.bounds.size.height != nil){
                    self.scrollHeight = self.scrollHeight + (self.oldLabel?.bounds.size.height)!
                }
                
                
                let newLabel = UILabel(frame: CGRectMake(20, self.scrollView.bounds.size.height + self.scrollHeight, self.view.bounds.size.width*(2/3)-20, textHeight! ))
                newLabel.font = self.cameraTextField.font
                newLabel.textColor = UIColor.whiteColor()
                ++self.scrollCounter
                newLabel.text = self.cameraTextField.text
                newLabel.numberOfLines = 0
                newLabel.sizeToFit()
                self.oldLabel = newLabel
                self.cameraTextField.text.removeAll()
                // print ((self.oldLabel?.bounds.size.height)!)
                //print (self.scrollHeight)
                self.scrollView.addSubview(newLabel)
                newLabel.transform = CGAffineTransformMakeScale(0.5, 0.5)
                UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                    newLabel.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: nil)
                
                
                
                //print (totalHeight)
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollHeight+(self.oldLabel?.bounds.size.height)!   )
                    }, completion: { (finished) -> Void in
                        
                        // print ((self.oldLabel?.bounds.size.height)! + self.scrollHeight)
                        UIView.animateWithDuration(2, animations: { () -> Void in
                            newLabel.alpha = 0.4
                        })
                })
                self.progressBar.hidden = false
                self.animatedBar.hidden = false
                let time = (Int)(newLabel.bounds.size.height/(self.cameraTextField.font?.lineHeight)!)
                //print (time)
                var duration:NSTimeInterval = 0
                switch (time){
                case 1:
                    duration = 1.5
                    
                    break
                case 2:
                    duration = 2.25
                    break
                case 3:
                    duration = 3.0
                    break
                case 4:
                    duration = 3.75
                    break
                case 5:
                    duration = 4.55
                    break
                default:
                    print("wtf 2 many lines")
                    break
                }
                animationBeginTimes.append(duration+1)
                let moveUp = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
                let scaleDown = POPSpringAnimation(propertyNamed: kPOPViewSize)
                /*======================================HERE================================================*/
                scaleDown.toValue = NSValue(CGSize: CGSize(width: self.typingButton.bounds.size.width*0.4, height: self.typingButton.bounds.size.height*0.6))
                moveUp.toValue = 27.5
                self.emojiLabel.hidden = true
                self.characterCounter.hidden = true
                self.typingButton.setTitle("look", forState: UIControlState.Normal)
                self.view.bringSubviewToFront(self.typingButton)
                self.view.bringSubviewToFront(self.progressBar)
                moveUp.completionBlock = { (animation, finished) in
                    arrayofText.addObject(newLabel.text!)
                    self.startRecording()
                    
                    UIView.animateWithDuration(duration, delay: 0, options: [], animations: { () -> Void in
                        self.animatedBar.transform = CGAffineTransformMakeScale(0.0001, 1)
                        }, completion: { (finished) -> Void in
                            if (finished){
                                
                                UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
                                    self.typingButton.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
                                    self.characterCounter.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
                                    self.emojiLabel.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
                                    }, completion: {(finished) -> Void in
                                        self.animatedBar.hidden = true
                                        self.animatedBar.transform = CGAffineTransformMakeScale(1, 1)
                                        self.progressBar.hidden = true
                                        self.stopRecording()
                                        self.characterCounter.text = "70"
                                        //self.emojiLabel.text = ("👆🏻")
                                        self.emojiLabel.hidden = false
                                        self.characterCounter.hidden = false
                                        self.view.bringSubviewToFront(self.emojiLabel)
                                        self.view.bringSubviewToFront(self.characterCounter)
                                        //self.typingButton.setTitleColor(UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.4), forState: UIControlState.Normal)
                                        //self.typingButton.backgroundColor = UIColor.init(colorLiteralRed: 1.00, green: 0.28, blue: 0.44, alpha: 1.0)
                                        self.typingButton.setTitle("record", forState: UIControlState.Normal)


                                        self.cameraTextField.returnKeyType = UIReturnKeyType.Send
                                        //self.longPressRecognizer.enabled = true
                                        self.typingButton.hidden = true
                                        self.emojiLabel.hidden = true
                                        self.characterCounter.hidden = true
                                        self.cameraTextField.becomeFirstResponder()
                                        self.typingButton.userInteractionEnabled = true
                                        self.typingButton.layer.borderWidth = 0
                                        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: [], animations: { () -> Void in                                                   self.typingButton.transform = CGAffineTransformMakeScale(1, 1)
                                            self.characterCounter.transform = CGAffineTransformMakeScale(1, 1)
                                            self.emojiLabel.transform = CGAffineTransformMakeScale(1, 1)
                                            }, completion: nil)
                                        
                                })
                            }
                            
                            
                    })
                }
                self.typingButton.pop_addAnimation(moveUp, forKey: "moveUP")
                self.typingButton.pop_addAnimation(scaleDown, forKey: "scaleDown")
                
                
                
                
                
            

            
        }
        
    }
    @IBOutlet weak var cameraTextField: UITextView!
    override func viewDidLoad() {
             // self.cameraTextField.spellCheckingType = UITextSpellCheckingType.Yes
        self.view.clipsToBounds = true
        super.viewDidLoad()



        let prefs = NSUserDefaults.standardUserDefaults()
        if let login = prefs.stringForKey("firstTime"){
            
            firstTime = false
        }else{
            
            prefs.setValue("didFirsTTime", forKey: "firstTime")
            // first time
            firstTime = true

        }



        self.header.backgroundColor = UIColor.clearColor()
        self.cakeTalkLabel.text = "caketalk"
        self.cakeTalkLabel.textColor = UIColor .blackColor() .colorWithAlphaComponent(0.5)
        self.cakeTalkLabel.font = UIFont(name:"RionaSans-Bold", size: 18.0)

        self.progressBar.hidden = true
        self.animatedBar.hidden = true
        self.cameraTextField.font = UIFont(name:"RionaSans-Bold", size: 22.0)
        characterCounter.layer.masksToBounds = true
        characterCounter.layer.cornerRadius = characterCounter.bounds.size.width/2
        characterCounter.layer.borderWidth = 1
        characterCounter.layer.borderColor = UIColor.whiteColor().CGColor
        characterCounter.layer.backgroundColor = UIColor.grayColor().CGColor
        self.cameraTextField.textContainer.lineFragmentPadding = 0
       // self.cameraTextField.autocorrectionType = UITextAutocorrectionType.Default
        self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollView.contentOffset.y+100)
        print ("loading camera...")
        // Initialize a gradient view

        quitScrollView.hidden = true
        clearAllScroll.hidden = true
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cameraView.longPressed(_:)))
        //longPressRecognizer.minimumPressDuration =
        self.view.addGestureRecognizer(longPressRecognizer)
        
        typingButton.titleLabel?.alpha = 0.4
        typingButton.titleLabel?.textAlignment = NSTextAlignment.Center
        typingButtonFrame = typingButton.frame
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cameraView.keyboardDidShow(_:)), name:UIKeyboardDidShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cameraView.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cameraView.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        if (UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front)){
            do{
                let files = try fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
                for file:NSString in files!{
                    try fileManager?.removeItemAtPath("\(NSTemporaryDirectory())\(file)")
                }
                //print (files)
                if (files?.count == 0){
                    clipCount = 1
                    //self.longPressRecognizer.enabled = false
                }
                
            }
            catch {
                print("bad")
            }

            
           // clipCount = 1;
            filteredImage = GPUImageView()
            videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .Front)
            videoCamera?.horizontallyMirrorFrontFacingCamera = true
            videoCamera!.outputImageOrientation = .Portrait
            filteredImage?.frame = self.view.bounds
            //print(filteredImage?.frame)
            filter = GPUImageMissEtikateFilter()
            //filter?.blurRadiusInPixels = 4
            videoCamera?.addTarget(filter)
            //print (filter)
            filter?.addTarget(filteredImage)
            self.view.insertSubview(filteredImage!, atIndex: 0)
            //self.view.insertSubview(imagePicker.view, aboveSubview: filteredImage!)
            videoCamera?.startCameraCapture()
            gradientView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)
            gradientView.backgroundColor = UIColor.clearColor()
            // Set the gradient colors
            gradientView.colors = [UIColor.clearColor(), UIColor.blackColor()]
            // Optionally set some locations
            gradientView.locations = [0, 1]
            
            // Optionally change the direction. The default is vertical.
            gradientView.direction = .Vertical
            gradientView.alpha = 0.7
            
            
            // Add it as a subview in all of its awesome
            self.view.insertSubview(gradientView, aboveSubview:filteredImage!)
        }
        else
        { // for simulator
            self.view.backgroundColor = UIColor.brownColor()
            typingButton.userInteractionEnabled = false
        }
        
       iPhoneScreenSizes()
       
    }
    override func viewWillAppear(animated: Bool) {
        
        self.typingButton.transform = CGAffineTransformMakeScale(0.5, 0.5)
        self.emojiLabel.transform = CGAffineTransformMakeScale(0.5, 0.5)
        self.characterCounter.transform = CGAffineTransformMakeScale(0.5, 0.5)
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { () -> Void in
            self.typingButton.transform = CGAffineTransformMakeScale(1, 1)
            self.emojiLabel.transform = CGAffineTransformMakeScale(1, 1)
            self.characterCounter.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
        do{
            let files = try fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
           // print (files)
            if (files?.count == 0){
                clipCount = 1
                scrollCounter = 0
                self.cameraTextField.resignFirstResponder()
                self.longPressRecognizer.enabled = false

                self.cameraTextField.returnKeyType = UIReturnKeyType.Default
                self.cameraTextField.becomeFirstResponder()
                self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                for subview in self.scrollView.subviews {
                    if subview is UILabel{
                        subview.removeFromSuperview()
                    }
                }
            }
            else{
                if (self.scrollView.contentOffset == CGPoint(x: 0, y: 0)){
                    self.scrollView.contentOffset = actualOffset
                }
             
            }
            
        }

        catch {
            print("bad")
        }
        //typingButton.transform = CGAffineTransformMakeScale(1, 1)
        if (self.cameraTextField.text.characters.count == 0){
            //typingButton.setTitle("start typing", forState: UIControlState.Normal)

            //emojiLabel.hidden = false
           // characterCounter.hidden = false
            //emojiLabel.text = "💬"
            self.cameraTextField.font = UIFont(name:"RionaSans-Bold", size: 22.0)

        }
        self.view.bringSubviewToFront(emojiLabel)
        self.view.bringSubviewToFront(characterCounter)
        super.viewWillAppear(animated)
        cameraTextField.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        cameraTextField.becomeFirstResponder()
        panGesture?.enabled = true
        shouldEdit = true
    }
    override func viewDidAppear(animated: Bool) {
        if (backWindow?.hidden == false){
            cameraTextField.delegate = self
        }
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: blur)
        let BlurSurface = UIView.init(frame: UIScreen.mainScreen().bounds)
        blurView.frame = UIScreen.mainScreen().bounds
        BlurSurface.addSubview(blurView)
        BlurSurface.alpha = 0
        frontWindow?.insertSubview(BlurSurface, atIndex: 1)
        self.cameraTextField.performSelector(#selector(UIResponder.becomeFirstResponder), withObject: nil, afterDelay: 0)
        if (firstTime == false){
            toolTip?.dismiss()
            var preferences = EasyTipView.Preferences()
            preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
            preferences.drawing.foregroundColor = UIColor.whiteColor()
            preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
            preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.Bottom
            toolTip = EasyTipView(text: "type: I like [something you like]", preferences: preferences, delegate: nil)
            toolTip!.show(forView: self.toolTipBut,
                          withinSuperview: self.view)
            
            
        }

    }
    override func viewWillDisappear(animated: Bool) {
       // print("disappear")
        shouldEdit = false
        self.cameraTextField.removeObserver(self, forKeyPath: "contentSize")
        actualOffset = self.scrollView.contentOffset
       // print (actualOffset)
        cameraTextField.resignFirstResponder()
        self.view.endEditing(true)
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
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        
        let  char = text.cStringUsingEncoding(NSUTF8StringEncoding)!
        let isBackSpace = strcmp(char, "\\b")
        //let textHeight = self.cameraTextField.font?.lineHeight
        //let textHeight = self.cameraTextField.font?.lineHeight
        if (textView.text != ""){
            shouldGoDown = true
        }
        if (isBackSpace == -92) {
           // print("Backspace was pressed")
            if (textView.text.characters.count == 1){
                toolTip?.dismiss()
                self.typingButton.hidden = true
                self.emojiLabel.hidden = true
                self.characterCounter.hidden = true
                
                var preferences = EasyTipView.Preferences()
                preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
                preferences.drawing.foregroundColor = UIColor.whiteColor()
                preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
                preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.Bottom
                toolTip = EasyTipView(text: "type: I like [something you like]", preferences: preferences, delegate: nil)
                toolTip!.show(forView: self.toolTipBut,
                              withinSuperview: self.view)
                

                
                
            }
            if (textView.text == ""){
                self.typingButton.hidden = true
                self.emojiLabel.hidden = true
                self.characterCounter.hidden = true
                if (scrollView.subviews.count > 0){
                    //scrollView.subviews[0]
                    if (scrollView.subviews[scrollView.subviews.count-1] is UILabel){
                        let buttonSpring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
                        let buttonSpring2 = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
                        buttonSpring.toValue = NSValue(CGPoint: CGPointMake(1, 1))
                        buttonSpring.velocity = NSValue(CGPoint: CGPointMake(6, 6))
                        buttonSpring.springBounciness = 20.0
                        buttonSpring2.toValue = NSValue(CGPoint: CGPointMake(1, 1))
                        buttonSpring2.velocity = NSValue(CGPoint: CGPointMake(6, 6))
                        buttonSpring2.springBounciness = 20.0
                        
                        //typingButton.setTitle("recordyourself", forState: UIControlState.Normal)
                        //typingButton.setTitleColor(UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.4), forState: UIControlState.Normal)
                        //typingButton.backgroundColor = UIColor.init(colorLiteralRed: 1, green: 0.52, blue: 0.68, alpha: 1.0)
                        //emojiLabel.text = "📹"
                        self.typingButton.hidden = false
                        self.emojiLabel.hidden = false
                        self.characterCounter.hidden = false
                   
                        if (clipCount > 0){
                            if (self.cameraTextField.returnKeyType == UIReturnKeyType.Send){
                                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                                    self.cameraTextField.resignFirstResponder()
                                    self.cameraTextField.returnKeyType = UIReturnKeyType.Default
                                    self.cameraTextField.becomeFirstResponder()
                                    
                                }
                            }
                            
                        }
                        typingButton.pop_addAnimation(buttonSpring, forKey: "spring")
                        emojiLabel.pop_addAnimation(buttonSpring2, forKey: "spring2")
                        characterCounter.pop_addAnimation(buttonSpring2, forKey: "spring2")
                        let newLabel = scrollView.subviews[scrollView.subviews.count-1] as! UILabel
                        cameraTextField.text = newLabel.text
                        --scrollCounter
                        clipCount -= 1

                        do{
                            let files = try fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
                            //let file = files[files?.endIndex-1]
                            try fileManager?.removeItemAtPath("\(NSTemporaryDirectory())\(clipCount).mov")
                            arrayofText.removeLastObject()
                            animationBeginTimes.removeLast()
                            print (files)
                            
                        }
                        catch let err {
                            print(err)
                        }
                        //self.cameraTextField.
                       // print ("newlabel\(newLabel.text)")
                        scrollHeight = scrollHeight - newLabel.bounds.size.height
                        self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollView.contentOffset.y-(self.cameraTextField.font?.lineHeight)!)
                        scrollView.subviews[scrollView.subviews.count-1].removeFromSuperview()
                    }
                }
                return false
                
            }

        }
        if (textView.text.characters.count == 0 && text != ""){
            if (text == "\n" && cameraTextField.returnKeyType == UIReturnKeyType.Send){
                //print ("go")
                cameraTextField.resignFirstResponder()
                self.view.bringSubviewToFront(typingButton)
               // let vc = self.storyboard?.instantiateViewControllerWithIdentifier("playerView") as! playerView
                self.cameraTextField.resignFirstResponder()
                self.view.endEditing(true)
              //  self.presentViewController(vc, animated: false, completion: nil)
                self.performSegueWithIdentifier("goPreview", sender: self)
                //typingButton.setTitle("", forState: UIControlState.Normal)
                emojiLabel.hidden = true
                characterCounter.hidden = true
               // typingButton.pop_addAnimation(goScale, forKey: "go")
                return false
            }
            else if (text == "\n" && cameraTextField.returnKeyType != UIReturnKeyType.Send){
                
                return false
            }
            toolTip?.dismiss()
            
            var preferences = EasyTipView.Preferences()
            preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
            preferences.drawing.foregroundColor = UIColor.whiteColor()
            preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
            preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.Bottom
            toolTip = EasyTipView(text: "tap record & do this", preferences: preferences, delegate: nil)
            toolTip!.show(forView: self.typingButton,
                          withinSuperview: self.view)
            let buttonSpring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            let buttonSpring2 = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            buttonSpring.toValue = NSValue(CGPoint: CGPointMake(1, 1))
            buttonSpring.velocity = NSValue(CGPoint: CGPointMake(6, 6))
            buttonSpring.springBounciness = 20.0
            buttonSpring2.toValue = NSValue(CGPoint: CGPointMake(1, 1))
            buttonSpring2.velocity = NSValue(CGPoint: CGPointMake(6, 6))
            buttonSpring2.springBounciness = 20.0
            self.typingButton.hidden = false
            self.emojiLabel.hidden = false
            self.characterCounter.hidden = false
            typingButton.pop_addAnimation(buttonSpring, forKey: "spring")
            emojiLabel.pop_addAnimation(buttonSpring2, forKey: "spring2")
            characterCounter.pop_addAnimation(buttonSpring2, forKey: "spring2")
            return true
            
        

        
    }
        
        
        

        
        if(cameraTextField.text.characters.count - range.length + text.characters.count > 70){
            //print ("too many")
            return false;
        }
        return true
    }
    func textViewDidChange(textView: UITextView) {
      /*  var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
        preferences.drawing.foregroundColor = UIColor.whiteColor()
        preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.Bottom
        
        EasyTipView.show(forView: self.typingButton,
                         withinSuperview: self.view,
                         text: "Tip view inside the navigation controller's view. Tap to dismiss!",
                         preferences: preferences,
                         delegate: nil)*/
        characterCounter.text = String(70-self.cameraTextField.text.characters.count)
        let textHeight = self.cameraTextField.font?.lineHeight
        let pos = self.cameraTextField.endOfDocument
        let currentRect = self.cameraTextField.caretRectForPosition(pos)
        if (currentRect.origin.y > previousRect.origin.y){
           // print ("up")
            self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollView.contentOffset.y + textHeight!)
            
        }
        else if (currentRect.origin.y < previousRect.origin.y){
          //  print ("down")
            if (shouldGoDown == true){
                
                self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollView.contentOffset.y - textHeight!)
                
            }
            
            
        }
        
        previousRect = currentRect;
        if (self.cameraTextField.text.characters.count == 0 && clipCount > 1){
          //  print ("send c")
           
            if (self.cameraTextField.returnKeyType == UIReturnKeyType.Default){

            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.cameraTextField.resignFirstResponder()
                self.cameraTextField.returnKeyType = UIReturnKeyType.Send
                self.cameraTextField.becomeFirstResponder()
                
                }
            }
        }
        else{
           // print (" need to change send button")
            if (self.cameraTextField.returnKeyType == UIReturnKeyType.Send){
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.cameraTextField.resignFirstResponder()
                    self.cameraTextField.returnKeyType = UIReturnKeyType.Default
                    self.cameraTextField.becomeFirstResponder()
                    
                }
                
                
                
            }
            
            
        }
        

        
    }
    func keyboardWillShow(notification: NSNotification) {
               //print (self.typingButton.frame)
        let userInfo = notification.userInfo!
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let convertedKeyboardEndFrame = view.convertRect(keyboardEndFrame, fromView: view.window)
        
        toolTipLayout.constant = CGRectGetMaxY(   view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame)
        panGesture?.enabled = true
        updateBottomLayoutConstraintWithNotification(notification)

    }
    func keyboardWillHide (notification: NSNotification) {
       // print ("keyboardwillhide")
        //gradientView.hidden = true
        updateBottomLayoutConstraintWithNotification(notification)
        
    }
    func keyboardDidShow(notification: NSNotification) {

    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let textView = object as! UITextView
        var topCorrect = (textView.bounds.size.height - textView.contentSize.height)
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        textView.contentInset.top = topCorrect

    }
    func updateBottomLayoutConstraintWithNotification(notification: NSNotification) {
       

        
        let userInfo = notification.userInfo!
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let convertedKeyboardEndFrame = view.convertRect(keyboardEndFrame, fromView: view.window)
                bottomLayoutConstraint.constant = CGRectGetMaxY(   view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame) + 10
        
        emoji.constant  = CGRectGetMaxY(view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame) + 25
        characterCountBottom.constant = CGRectGetMaxY(view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame) + 20
        if (self.cameraTextField.returnKeyType == UIReturnKeyType.Default){
        if (CGRectGetMaxY(view.bounds) != CGRectGetMinY(convertedKeyboardEndFrame)){
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                //print ("uh oh")
                self.bottomScrollView.constant  = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame) +
                    self.typingButton.bounds.height + 11 + 10 + 50
                self.textViewBottom.constant = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame) + self.typingButton.bounds.height + 10 + 11
               
            }
            }
            
            
        }
        
    }
    func createImagePicker() {
        print ("create image picker")
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Video
            imagePicker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            imagePicker.allowsEditing = false
            imagePicker.showsCameraControls = false
            imagePicker.cameraViewTransform = CGAffineTransformIdentity
            
            if (UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front)){
                print ("has camera device")
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
            }
            else{
                print ("no camera device")
            }
            imagePicker.videoQuality = UIImagePickerControllerQualityType.Type640x480
            imagePicker.delegate = self
            imagePicker.extendedLayoutIncludesOpaqueBars = true
            imagePicker.view.userInteractionEnabled = false
            
            
        }


        
    }
    func startRecording() {
        print ("starting recording...")
        recording = true;
        let clipCountString = String(clipCount)
        movieWriter = GPUImageMovieWriter(movieURL: NSURL.fileURLWithPath("\(NSTemporaryDirectory())\(clipCountString).mov",isDirectory: true), size: view.frame.size)
        filter?.addTarget(movieWriter)


        movieWriter?.encodingLiveVideo = true
        movieWriter?.shouldPassthroughAudio = false

        movieWriter?.startRecording()
//        self.toolTip?.dismiss()

        
    }
    func stopRecording() {
        newImage?.removeFromSuperview()
        print ("stopping recording...")
        clipCount += 1
        recording = false;
        showStatusBar(true)
        self.header.alpha = 0.75
        movieWriter?.finishRecording()

        self.cakeTalkLabel.hidden = false
        self.longPressRecognizer.enabled = true
        let index = clipCount - 1
        exportVideo(index)
       // let files = fileManager.contentsOfDirectoryAtPath(NSTemporaryDirectory(), error: error) as? [String]
        toolTip?.dismiss()
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
        preferences.drawing.foregroundColor = UIColor.whiteColor()
        preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.Bottom
        toolTip = EasyTipView(text: "type: I like [something you like]", preferences: preferences, delegate: nil)
        toolTip!.show(forView: self.toolTipBut,
                      withinSuperview: self.view)
        

       
    }
    func longPressed(sender: UILongPressGestureRecognizer)
    {

        

        if (sender.state == UIGestureRecognizerState.Began){
                        // Put it somewhere, give it a frame...
            self.header.backgroundColor = UIColor.orangeColor()
            self.cakeTalkLabel.text = "edit"
            self.typingButton.userInteractionEnabled = false
            panGesture?.enabled = false
            sender.enabled = false
            let blurEffect = UIBlurEffect(style: .Dark)
            let blurOverlay = UIVisualEffectView()
            
            
            let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
            let vibrantOverlay = UIVisualEffectView(effect: vibrancyEffect)
            let overlayScrollView = UIScrollView(frame: CGRectMake(20,40+self.header.bounds.size.height,self.view.bounds.size.width-20,2*self.view.bounds.height/3))
           // print (overlayScrollView.frame)
            overlayScrollView.showsVerticalScrollIndicator = true
            overlayScrollView.indicatorStyle = UIScrollViewIndicatorStyle.White
            overlayScrollView.userInteractionEnabled = true
            overlayScrollView.scrollEnabled = true
            overlayScrollView.delegate = self
           
            //overlayScrollView.contentSize
            blurOverlay.frame = self.view.bounds
            vibrantOverlay.frame = self.view.bounds
            self.view.addSubview(blurOverlay)
            
            var scrollHeightOverlay:CGFloat = 0.0
           

            
            vibrantOverlay.contentView.addSubview(overlayScrollView)
            blurOverlay.contentView.addSubview(vibrantOverlay)
                      for subview in scrollView.subviews{
                if subview is UILabel{
                    let olderLabel = subview as! UILabel
                    let newerLabel = UILabel(frame: CGRectMake(20, scrollHeightOverlay, self.view.bounds.size.width*(2/3)-20, 25))
                    
                    newerLabel.font = UIFont(name: "Avenir Next", size: 22)
                    newerLabel.textColor = UIColor.whiteColor()
                    newerLabel.text = olderLabel.text
                    newerLabel.numberOfLines = 0
                    newerLabel.sizeToFit()
                    overlayScrollView.addSubview(newerLabel)
                    let border = CALayer()
                    border.frame = CGRectMake(0 , scrollHeightOverlay+40+self.header.bounds.size.height, 2, CGRectGetHeight(newerLabel.frame)+10)
                    border.backgroundColor = UIColor.orangeColor().CGColor;
                    vibrantOverlay.layer.addSublayer(border)
                    scrollHeightOverlay = scrollHeightOverlay + newerLabel.bounds.size.height + 10


                }
                
            }
            overlayScrollView.contentSize = CGSizeMake(self.view.bounds.size.width-20,scrollHeightOverlay)
            let timeStampLabel = UILabel(frame: CGRectMake(20, overlayScrollView.contentSize.height , self.view.bounds.size.width*(2/3)-20,25))
            timeStampLabel.font = UIFont(name:"Avenir Next", size:15)
            timeStampLabel.textColor = UIColor.whiteColor()
            timeStampLabel.text = "now"
            timeStampLabel.numberOfLines = 0
            timeStampLabel.sizeToFit()
            overlayScrollView.addSubview(timeStampLabel)
            let emojiLabel = UILabel(frame: CGRectMake(20, overlayScrollView.contentSize.height+20, self.view.bounds.size.width*(2/3)-20,25))
            emojiLabel.font = UIFont(name:"Avenir Next", size:15)
            emojiLabel.textColor = UIColor.whiteColor()
            emojiLabel.text = "📖"
            emojiLabel.numberOfLines = 0
            timeStampLabel.sizeToFit()
            overlayScrollView.addSubview(emojiLabel)

            
            clearAllScroll.transform = CGAffineTransformMakeTranslation(0, 2000)
            quitScrollView.transform = CGAffineTransformMakeTranslation(0, 2000)
            overlayScrollView.transform = CGAffineTransformMakeTranslation (0, -1000)
            clearAllScroll.hidden = false
            quitScrollView.hidden = false
            var preferences = EasyTipView.Preferences()
            preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
            preferences.drawing.foregroundColor = UIColor.whiteColor()
            preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
            preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.Bottom
            self.toolTip?.dismiss()
            self.toolTip = EasyTipView(text: "careful this deletes stuff", preferences: preferences, delegate: nil)

            cameraTextField.resignFirstResponder()
            UIView.animateWithDuration(0.1, animations: {
                blurOverlay.effect = blurEffect
                }, completion: {
                    finished in
                    if (finished){
                        let line = UIView(frame: CGRectMake(0,self.quitScrollView.frame.origin.y-10, self.view.bounds.size.width, 1))
                        line.backgroundColor = UIColor.whiteColor()
                        self.view.addSubview(line)
                        


                        overlayScrollView.flashScrollIndicators()
                        self.view.bringSubviewToFront(self.clearAllScroll)
                        self.view.bringSubviewToFront(self.quitScrollView)
                        self.view.bringSubviewToFront(self.header)
                        self.view.bringSubviewToFront(line)
                        self.view.bringSubviewToFront(self.toolTip!)
                       
                                               UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 3, options: .CurveEaseInOut, animations: {
                           
                            self.quitScrollView.transform = CGAffineTransformMakeTranslation(0, 0)
                            overlayScrollView.transform = CGAffineTransformMakeTranslation(0, 0)
                            self.view.layoutIfNeeded()
                            }) { _ in
                                let buttonSpring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
                               
                                buttonSpring.toValue = NSValue(CGPoint: CGPointMake(1, 1))
                                buttonSpring.velocity = NSValue(CGPoint: CGPointMake(6, 6))
                                buttonSpring.springBounciness = 20.0
                               
                                self.weGoodEmoji.hidden = false
                                self.view.bringSubviewToFront(self.weGoodEmoji)
                                self.weGoodEmoji.pop_addAnimation(buttonSpring, forKey: "spring")
                        }
                        UIView.animateWithDuration(0.5, delay: 0.1, usingSpringWithDamping: 0.85, initialSpringVelocity: 3, options: .CurveEaseInOut, animations: {
                            self.clearAllScroll.transform = CGAffineTransformMakeTranslation(0, 0)
                            
                            }) { _ in
                                let buttonSpring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
                                
                                buttonSpring.toValue = NSValue(CGPoint: CGPointMake(1, 1))
                                buttonSpring.velocity = NSValue(CGPoint: CGPointMake(6, 6))
                                buttonSpring.springBounciness = 20.0
                                self.clearAllEmoji.hidden = false
                                self.view.bringSubviewToFront(self.clearAllEmoji)
                                self.clearAllEmoji.pop_addAnimation(buttonSpring, forKey: "spring")
                                self.toolTip!.show(forView: self.clearAllScroll,
                                    withinSuperview: self.view)
                        }
                    }
            })
            //print("longpressed")
        }

    }
    func iPhoneScreenSizes(){
        let bounds = UIScreen.mainScreen().bounds
        let height = bounds.size.height
        
        switch height {
        case 480.0:
           // print("iPhone 3,4")
            self.cameraTextField.font = UIFont(name: "AvenirNext-Medium", size: 24)
        case 568.0:
            //print("iPhone 5")
            self.cameraTextField.font = UIFont(name: "AvenirNext-Medium", size: 24)
        case 667.0:
            //print("iPhone 6")
            self.cameraTextField.font = UIFont(name: "AvenirNext-Medium", size: 28.5)
        case 736.0:
            //print("iPhone 6+")
            self.cameraTextField.font = UIFont(name: "AvenirNext-Medium", size: 25 )
        default:
            break
            //print("not an iPhone")
            
        }
        
        
    }
    func exportVideo(index: Int) -> Bool{
        print ("exporting video...")
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let destinationPath = documentsPath.stringByAppendingPathComponent("movie.mov")
        let outputPath =  NSURL.fileURLWithPath("\(NSTemporaryDirectory())movie.mov")
        
        
        let composition = AVMutableComposition()
        //let timeStartArray = Array[Double]
        var movieTimes:Array = [CMTime]()
        let trackVideo:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        let insertTime = kCMTimeZero
        do{
            try NSFileManager().removeItemAtURL(outputPath)
        }
        catch{
            print("no movie")
        }
        do{
            
            
            
            let files = try fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
            print (files)
            for i in 1..<files!.count+1{
                print ("files: \(files!.count+1-i)")
                let avAsset = AVAsset(URL: NSURL.fileURLWithPath("\(NSTemporaryDirectory())\(files!.count+1-i).mov"))
                
                print (avAsset.duration)
                movieTimes.append(avAsset.duration)
                let tracks = avAsset.tracksWithMediaType(AVMediaTypeVideo)
                if tracks.count > 0{
                    let assetTrack:AVAssetTrack = tracks[0] as AVAssetTrack
                    try trackVideo.insertTimeRange(CMTimeRangeMake(kCMTimeZero,avAsset
                        .duration), ofTrack: assetTrack, atTime: insertTime)
                    
                    //insertTime = CMTimeAdd(insertTime, sourceAsset.duration)
                }
                
            }

        }
            
        catch {
            print("bad")
        }
        
        let videotrack = composition.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
        let videoComposition = AVMutableVideoComposition()
        let instruction = AVMutableVideoCompositionInstruction()
       // instruction.enablePostProcessing = true
        videoComposition.frameDuration = CMTimeMake(1, 80)
        videoComposition.renderSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
        instruction.layerInstructions = NSArray(object: layerinstruction) as! [AVVideoCompositionLayerInstruction]
        //layerinstruction.setTransform( CGAffineTransformMakeTranslation(0, 320), atTime:kCMTimeZero)
        videoComposition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
        
        /*


        // 1
        let overlayLayer1: CALayer = CALayer()
        let currentTime = CACurrentMediaTime()
        overlayLayer1.geometryFlipped = true
        // overlayLayer1.contents = (animationImage.CGImage as! AnyObject)
        overlayLayer1.frame = self.view.bounds
       // overlayLayer1.masksToBounds = true
        
        // 2 - translate
        //for i in 1..<files!.count+1
        
        for i in 0..<(arrayofText.count){
        var beginTime:CMTime = CMTime(value: 0, timescale: 1)
            
        let scrollLabel = PaddingLabel()
        scrollLabel.frame = CGRectMake(20,self.view.bounds.size.height*0.55, self.view.bounds.size.width*(2/3)-20,50)
        scrollLabel.textColor = UIColor.whiteColor()
        
        scrollLabel.font = UIFont(name:"RionaSans-Bold", size: 22.0)
        scrollLabel.text = (arrayofText.objectAtIndex(i) as! String)
        scrollLabel.numberOfLines = 0
        scrollLabel.sizeToFit()
        scrollLabel.layer.cornerRadius = 10
        scrollLabel.layer.opacity = 0.0
        scrollLabel.layer.masksToBounds = true
        //scrollLabel.alpha = 0
        scrollLabel.backgroundColor = randomColor(hue: .Random, luminosity: .Light) .colorWithAlphaComponent(0.7)
        
        scrollLabel.setLineHeight(0)
        scrollLabel.layer.display()
            //scrollLabel.alignmentMode =
           // scrollLabel.setLineHeight(0)
            // scrollLabel.frame.origin.y = self.view.bounds.size.height/2-scrollLabel.bounds.size.height/2
           
        for j in 0..<(i){
            
           beginTime = beginTime + movieTimes[j]
        }
        
        print ("begin\(CMTimeGetSeconds(beginTime))")

        let animation: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)

        animation.duration = CMTimeGetSeconds(movieTimes[i]) + 4.25
        animation.repeatCount = 0
        animation.autoreverses = false
        animation.fromValue = scrollLabel.frame.origin.y
        animation.toValue = self.AVCoreAnimationBeginTimeAtZero.bounds.size.height/3 - scrollLabel.bounds.size.height
        animation.beginTime = kCMTimeZero//currentTime + CMTimeGetSeconds(beginTime)
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
            animation2.duration = CMTimeGetSeconds(movieTimes[i]) + 4.25
            animation2.repeatCount = 0
            animation2.autoreverses = false
            animation2.toValue = 0
            animation2.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
            scrollLabel.layer.pop_addAnimation(animation2, forKey: "goDisappear")
        }
        scrollLabel.layer.pop_addAnimation(animation, forKey: "goUP")
        scrollLabel.layer.pop_addAnimation(animation3, forKey: "spring")
        scrollLabel.layer.pop_addAnimation(animation4, forKey: "goAppear")
        print (animation.beginTime - currentTime)
        print (animation4.beginTime - currentTime)
        print(animation3.beginTime - currentTime)


        overlayLayer1.addSublayer(scrollLabel.layer)
        }
           // let labelSpring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            
        
      
       // scrollLabel.shouldRasterize = true
           

        let parentLayer: CALayer = CALayer()
        let videoLayer: CALayer = CALayer()
        parentLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)
        videoLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer1)
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)*/
        let movieOutput = GPUImageMovieWriter(movieURL: outputPath, size: self.view.bounds.size)
        let outputFilter = GPUImageSepiaFilter()
        outputFilter.addTarget(movieOutput)
        movieComposition = GPUImageMovieComposition(composition: composition, andVideoComposition: videoComposition, andAudioMix: nil)
     //   movieComposition!.playAtActualSpeed = true
        movieComposition!.enableSynchronizedEncodingUsingMovieWriter(movieOutput)
        movieComposition!.addTarget(movieOutput)
        
        movieOutput.startRecording()
        movieComposition!.startProcessing()
        
        
         //export 1 small file and 1 large file into the full compilated video file then add animation begin times based on switch statemente from typingbutton
            
        
        return true
    }
    func makeAttributedString(title: String) -> NSAttributedString {
        let titleAttributes = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        
        
      
        
        return titleString
    }

}


extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.Top:
            border.frame = CGRectMake(0, 0, CGRectGetHeight(self.frame), thickness)
            break
        case UIRectEdge.Bottom:
            border.frame = CGRectMake(0, CGRectGetHeight(self.frame) - thickness, UIScreen.mainScreen().bounds.width, thickness)
            break
        case UIRectEdge.Left:
            border.frame = CGRectMake(-25 , 0, thickness, CGRectGetHeight(self.frame))
            break
        case UIRectEdge.Right:
            border.frame = CGRectMake(CGRectGetWidth(self.frame) - thickness, 0, thickness, CGRectGetHeight(self.frame))
            break
        default:
            break
        }
        
        border.backgroundColor = color.CGColor;
        
        self.addSublayer(border)
    }
    
}


