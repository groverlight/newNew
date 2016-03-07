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
import Parse
import Bolts

var frontWindow: UIWindow?
var arrayofText: NSMutableArray = []
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
    var movieWriter: GPUImageMovieWriter?
    var clipCount = 1
    var fileManager: NSFileManager? = NSFileManager()
    var longPressRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!

    @IBOutlet weak var quitScrollView: UIButton!
    @IBOutlet weak var clearAllScroll: UIButton!
    @IBOutlet weak var bottomScrollView: NSLayoutConstraint!
    @IBAction func clearScrollAct(sender: AnyObject) {
        quitScrollView.hidden = true
        clearAllScroll.hidden = true
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
        self.cameraTextField.returnKeyType = UIReturnKeyType.Send
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.quitScrollView.transform = CGAffineTransformMakeTranslation(0, 2000)
            self.clearAllScroll.transform = CGAffineTransformMakeTranslation(0, 2000)
            }) { (finished) -> Void in
                self.quitScrollView.hidden = true
                self.clearAllScroll.hidden = true
                for subview in self.view.subviews {
                    if subview is UIVisualEffectView {
                        subview.removeFromSuperview()
                    }
                }
                
               self.cameraTextField.becomeFirstResponder()
        }

    }
    @IBAction func quitScrollAct(sender: AnyObject) {

        self.typingButton.userInteractionEnabled = true
        panGesture?.enabled = true
        longPressRecognizer.enabled = true
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.quitScrollView.transform = CGAffineTransformMakeTranslation(0, 2000)
            self.clearAllScroll.transform = CGAffineTransformMakeTranslation(0, 2000)
            }) { (finished) -> Void in
                self.quitScrollView.hidden = true
                self.clearAllScroll.hidden = true
                for subview in self.view.subviews {
                    if subview is UIVisualEffectView {
                        subview.removeFromSuperview()
      
                    }
                }
                
                self.cameraTextField.becomeFirstResponder()
        }
    }

    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var emoji: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var typingButton: UIButton!
    @IBAction func typingButtonFunc(sender: AnyObject) {
        if (cameraTextField.text.characters.count == 0){

            typingButton.userInteractionEnabled = false
            emojiLabel.userInteractionEnabled = false
            let buttonNo = POPSpringAnimation (propertyNamed: kPOPLayerPositionX)
            buttonNo.springBounciness = 20
            buttonNo.velocity = (1000)
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
                }
            }
            emojiLabel.pop_addAnimation(buttonNo2, forKey: "shake2")
            typingButton.pop_addAnimation(buttonNo, forKey: "shake")

            
        }
        else{
            //print(oldLabel?.bounds.size.height)
            let textHeight = self.cameraTextField.font?.lineHeight
            shouldGoDown = false
            if (oldLabel?.bounds.size.height != nil){
                scrollHeight = scrollHeight + (oldLabel?.bounds.size.height)!
            }
            

            let newLabel = UILabel(frame: CGRectMake(0, scrollView.bounds.size.height + scrollHeight, scrollView.bounds.size.width, textHeight! ))
            newLabel.font = self.cameraTextField.font
            newLabel.textColor = UIColor.whiteColor()
            ++scrollCounter
            newLabel.text = cameraTextField.text
            newLabel.numberOfLines = 0
            newLabel.sizeToFit()
            oldLabel = newLabel
            cameraTextField.text.removeAll()
            // print ((self.oldLabel?.bounds.size.height)!)
            //print (self.scrollHeight)
            scrollView.addSubview(newLabel)
            //print (totalHeight)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollHeight+(self.oldLabel?.bounds.size.height)!   )
                }, completion: { (finished) -> Void in
                    // print ((self.oldLabel?.bounds.size.height)! + self.scrollHeight)
                    UIView.animateWithDuration(2, animations: { () -> Void in
                        newLabel.alpha = 0.4
                    })
            })
            
            typingButton.userInteractionEnabled = false
            cameraTextField.resignFirstResponder()
            //cameraTextField.
            panGesture?.enabled = false

            let typeButtonHeight = self.typingButton.bounds.size.height

            let buttonDecay = POPBasicAnimation(propertyNamed: kPOPViewSize)
            let buttonDecay2 = POPBasicAnimation(propertyNamed: kPOPViewSize)
            let circle = CircleView(frame: CGRectMake(self.typingButton.frame.origin.x + 3*self.typingButton.bounds.size.width/2, self.self.typingButton.frame.origin.y+3*self.typingButton.bounds.size.height/2, self.typingButton.bounds.size.height, self.self.typingButton.bounds.size.height))
            self.view.addSubview(circle)
            circle.hidden = true
            circle.translatesAutoresizingMaskIntoConstraints = false
          //  let circlewidth = circle.bounds.size.width
            circle.bottomAnchor.constraintEqualToAnchor(self.typingButton.topAnchor).active = true
           // circle.centerXAnchor.constraintEqualToAnchor(self.typingButton.centerXAnchor).active = true
            circle.centerXAnchor.constraintEqualToAnchor(self.typingButton.centerXAnchor, constant: -circle.bounds.size.width/2).active = true
            //circle.centerYAnchor.constraintEqualToAnchor(self.typingButton.centerYAnchor, constant:0).active = true
            
            buttonDecay2.toValue = NSValue(CGSize: CGSize(width: typeButtonHeight/3, height: typeButtonHeight/3))
            buttonDecay.toValue = NSValue(CGSize: CGSize(width: typeButtonHeight, height: typeButtonHeight))
            buttonDecay.duration = 0.3
            buttonDecay2.duration = 0.0000

            buttonDecay.completionBlock = { (animation, finished) in
                
                self.typingButton.hidden = true
                self.typingButton.backgroundColor = UIColor.init(colorLiteralRed: 1.00, green: 0.28, blue: 0.44, alpha: 1.0)
                self.typingButton.layer.borderWidth = 0
               // self.typingButton.transform = CGAffineTransformMakeScale(0, 0)
                self.typingButton.pop_addAnimation(buttonDecay2, forKey: "decay2")
                circle.strokeColor = UIColor.whiteColor()
                circle.hidden = false
                self.cameraTextField.sizeToFit()
               let time = (Int)(newLabel.bounds.size.height/(self.cameraTextField.font?.lineHeight)!)
               
                print (time)

                switch (time){
                case 1:
                    circle.animateToStrokeEnd(2)
                    break
                case 2:
                    circle.animateToStrokeEnd(2.75)
                    break
                case 3:
                    circle.animateToStrokeEnd(3.5)
                    break
                case 4:
                    circle.animateToStrokeEnd(4.25)
                    break
                case 5:
                    circle.animateToStrokeEnd(5)
                    break
                default:
                    print("wtf 2 many lines")
                    break
                }
                
                
                arrayofText.addObject(self.cameraTextField.text)
                // print ("start recording")
                //  typingButton.pop_addAnimation(buttonScale, forKey: "scale")
            }
            
            buttonDecay2.completionBlock = { (animation, finished) in
                self.typingButton.hidden =  false
                self.typingButton.layer.cornerRadius = self.typingButton.bounds.size.width/2
                let scaleUp = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
                scaleUp.toValue=NSValue(CGSize: CGSizeMake(1, 1))
                scaleUp.duration = 2
                scaleUp.completionBlock = { (animation, finished) in
                    self.typingButton.transform = CGAffineTransformMakeScale(1, 1)
                    self.stopRecording()
                    let recover = POPSpringAnimation(propertyNamed: kPOPViewSize)
                    recover.toValue = NSValue(CGSize: CGSize(width: self.view.bounds.size.width-60, height: self.typingButtonFrame.size
                        .height))

                    recover.springBounciness = 20
                    //recover.springSpeed =
                    recover.springSpeed = 100
                    recover.completionBlock = { (animation, finished) in
                        if (finished) {

                            self.typingButton.layer.cornerRadius = 8
                            panGesture?.enabled = true
                            
                            let yanim = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
                            yanim.springBounciness = 20
                            yanim.velocity = (500)
                            yanim.springSpeed = 50
                            yanim.completionBlock = { (animation, finished) in
                                if (finished){
                                    
                                    let yanim2 = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
                                    yanim2.springBounciness = 20
                                    yanim2.velocity = (500)
                                    yanim2.springSpeed = 50
                                    yanim2.completionBlock = { (animation,finished) in
                                        self.typingButton.userInteractionEnabled = true

                                    }
                                    self.typingButton.pop_addAnimation(yanim2, forKey: "nod2")
                                    
                                }
                            }
                            newLabel.layer.pop_addAnimation(yanim, forKey: "nod")

                        }
                    
                    }
                    
                    self.emojiLabel.text = ("👆")
                    self.emojiLabel.hidden = false

                    self.typingButton.setTitleColor(UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.4), forState: UIControlState.Normal)
                    
                    self.typingButton.setTitle("another one", forState: UIControlState.Normal)
                    self.typingButton.pop_addAnimation(recover, forKey: "recover")
                    self.cameraTextField.returnKeyType = UIReturnKeyType.Send
                    self.cameraTextField.becomeFirstResponder()
                    

                }
                self.typingButton.pop_addAnimation(scaleUp, forKey: "scaleup")
                //circle.pop_addAnimation(scaleUp2, forKey: "scaleup")

                
            }
                //[NSValue valueWithCGSize:CGSizeMake(3, 2)];
            self.startRecording()
            self.typingButton.setTitleColor(UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.4), forState: UIControlState.Normal)
            self.typingButton.setTitle("", forState: UIControlState.Normal)
            self.emojiLabel.hidden = true
            self.typingButton.layer.cornerRadius = 25
            self.typingButton.layer.borderWidth = 2.0
            self.typingButton.clipsToBounds = true
            typingButton.pop_addAnimation(buttonDecay, forKey: "decay")
        }
    }
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var cameraTextField: UITextView!
    override func viewDidLoad() {
        self.cameraTextField.spellCheckingType = UITextSpellCheckingType.Yes
        self.view.clipsToBounds = true
        super.viewDidLoad()
       // self.cameraTextField.autocorrectionType = UITextAutocorrectionType.Default
       print ("cameraView laoded")

        //self.cameraTextField.enablesReturnKeyAutomatically = false;
        quitScrollView.hidden = true
        clearAllScroll.hidden = true
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
        longPressRecognizer.minimumPressDuration = 1.5
        
        self.view.addGestureRecognizer(longPressRecognizer)
        typingButton.titleLabel?.alpha = 0.4
        typingButton.titleLabel?.textAlignment = NSTextAlignment.Center
        typingButtonFrame = typingButton.frame
        cameraTextField.delegate = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        if (UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front)){
            do{
                let files = try fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
                for file:NSString in files!{
                    try fileManager?.removeItemAtPath("\(NSTemporaryDirectory())\(file)")
                }
                //print (files)
                if (files?.count == 0){
                    clipCount = 1
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
        }
        else
        { // for simulator
            self.view.backgroundColor = UIColor.brownColor()
            typingButton.userInteractionEnabled = false
        }
        
       iPhoneScreenSizes()
    }
    override func viewWillAppear(animated: Bool) {
       // print ("appear")
        // print ("view will appear deleting files")
        //print (files)
        do{
            let files = try fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
           // print (files)
            if (files?.count == 0){
                clipCount = 1
                scrollCounter = 0
                self.cameraTextField.resignFirstResponder()
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
                //print(self.scrollView.contentOffset)
               // self.scrollView.contentOffset
                    //{x:0, y:self.scrollView.contentOffset + self.cameraTextField.font}
            }
            
        }

        catch {
            print("bad")
        }
        
        typingButton.transform = CGAffineTransformMakeScale(1, 1)
        typingButton.setTitle("start typing", forState: UIControlState.Normal)

        emojiLabel.hidden = false
        emojiLabel.text = "💬"
        self.view.bringSubviewToFront(emojiLabel)
        super.viewWillAppear(animated)
        cameraTextField.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        cameraTextField.becomeFirstResponder()
        panGesture?.enabled = true
        shouldEdit = true
    }
    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated)
        let theRect = imagePicker.view.frame
        cameraPreview?.frame = theRect
        //imagePicker.cameraOverlayView = cameraPreview
        //self.presentViewController(imagePicker, animated: animated, completion: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        print("disappear")
        shouldEdit = false
        //cameraTextField.removeObserver(self, forKeyPath: "contentSize")
        actualOffset = self.scrollView.contentOffset
       // print (actualOffset)
        cameraTextField.resignFirstResponder()
        self.view.endEditing(true)
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //print ("textview changed")
      /*  if  ((Int)(cameraTextField.contentSize.height/(self.cameraTextField.font?.lineHeight)!) == 2){
        self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollView.contentOffset.y+50.0)
        }*/

        let  char = text.cStringUsingEncoding(NSUTF8StringEncoding)!
        let isBackSpace = strcmp(char, "\\b")
        //let textHeight = self.cameraTextField.font?.lineHeight
        //let textHeight = self.cameraTextField.font?.lineHeight
        if (textView.text != ""){
            shouldGoDown = true
        }
        if (isBackSpace == -92) {
           // print("Backspace was pressed")
            
            if (textView.text == ""){
                
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
                        typingButton.layer.borderColor = UIColor.whiteColor().CGColor
                        typingButton.layer.borderWidth  = 2
                        typingButton.setTitle("record yourself", forState: UIControlState.Normal)
                        typingButton.setTitleColor(UIColor.init(colorLiteralRed: 1.00, green: 0.28, blue: 0.44, alpha: 1.0), forState: UIControlState.Normal)
                        typingButton.titleLabel?.alpha = 1
                        typingButton.backgroundColor = .clearColor()
                        emojiLabel.text = "📹"
                        typingButton.pop_addAnimation(buttonSpring, forKey: "spring")
                        emojiLabel.pop_addAnimation(buttonSpring2, forKey: "spring2")
                        let newLabel = scrollView.subviews[scrollView.subviews.count-1] as! UILabel
                        cameraTextField.text = newLabel.text
                        --scrollCounter
                        --clipCount

                        do{
                            let files = try fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
                            //let file = files[files?.endIndex-1]
                            try fileManager?.removeItemAtPath("\(NSTemporaryDirectory())\(clipCount).m4v")
                            
                            print (files)
                            
                        }
                        catch {
                            print("bad")
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
                let goScale = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
                goScale.toValue = NSValue(CGPoint: CGPointMake(10, 30))
                goScale.completionBlock = { (animated,finished) in
                goScale.duration = 0.01
                    //let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("sendView") as! sendView
                    self.cameraTextField.resignFirstResponder()
                    //self.view.endEditing(true)
                    self.presentViewController(vc, animated: false, completion: nil)
                    //self.performSegueWithIdentifier("goSend", sender: self)
                }
                typingButton.setTitle("", forState: UIControlState.Normal)
                emojiLabel.hidden = true
                typingButton.pop_addAnimation(goScale, forKey: "go")
                return false
            }
            else if (text == "\n" && cameraTextField.returnKeyType != UIReturnKeyType.Send){
                
                return false
            }
            let buttonSpring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            let buttonSpring2 = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            buttonSpring.toValue = NSValue(CGPoint: CGPointMake(1, 1))
            buttonSpring.velocity = NSValue(CGPoint: CGPointMake(6, 6))
            buttonSpring.springBounciness = 20.0
            buttonSpring2.toValue = NSValue(CGPoint: CGPointMake(1, 1))
            buttonSpring2.velocity = NSValue(CGPoint: CGPointMake(6, 6))
            buttonSpring2.springBounciness = 20.0
            typingButton.layer.borderColor = UIColor.whiteColor().CGColor
            typingButton.layer.borderWidth  = 2
            typingButton.setTitle("record yourself", forState: UIControlState.Normal)
            typingButton.setTitleColor(UIColor.init(colorLiteralRed: 1.00, green: 0.28, blue: 0.44, alpha: 1.0), forState: UIControlState.Normal)
            typingButton.titleLabel?.alpha = 1
            typingButton.backgroundColor = .clearColor()
            emojiLabel.text = "📹"
            typingButton.pop_addAnimation(buttonSpring, forKey: "spring")
            emojiLabel.pop_addAnimation(buttonSpring2, forKey: "spring2")
            
        }
        else if (textView.text.characters.count == 1 && range.length == 1){
            if (clipCount == 1){
            typingButton.layer.borderWidth = 0
            typingButton.setTitleColor(UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.4), forState: UIControlState.Normal)
            typingButton.setTitle("start typing", forState: UIControlState.Normal)
            typingButton.backgroundColor = UIColor.init(colorLiteralRed: 1.00, green: 0.28, blue: 0.44, alpha: 1.0)
            typingButton.titleLabel?.alpha  = 0.4
            emojiLabel.text = "💬"
            }
            else{
                typingButton.layer.borderWidth = 0
                typingButton.setTitleColor(UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.4), forState: UIControlState.Normal)
                typingButton.setTitle("another one", forState: UIControlState.Normal)
                typingButton.backgroundColor = UIColor.init(colorLiteralRed: 1.00, green: 0.28, blue: 0.44, alpha: 1.0)
                typingButton.titleLabel?.alpha  = 0.4
                emojiLabel.text = "👆"
            }

        }
        
        
        

        
        if(cameraTextField.text.characters.count - range.length + text.characters.count > 90){
            //print ("too many")
            return false;
        }
        return true
    }
    func textViewDidChange(textView: UITextView) {
        let textHeight = self.cameraTextField.font?.lineHeight
        let pos = self.cameraTextField.endOfDocument
        let currentRect = self.cameraTextField.caretRectForPosition(pos)
        if (currentRect.origin.y > previousRect.origin.y){
            print ("go up")
            
            self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollView.contentOffset.y + textHeight!)
            
        }
        else if (currentRect.origin.y < previousRect.origin.y){
            print ("go down")
            if (shouldGoDown == true){
                
                self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollView.contentOffset.y - textHeight!)
                
            }
            
            
        }
        
        previousRect = currentRect;
        if (self.cameraTextField.text.characters.count == 0 && clipCount > 1){
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.cameraTextField.resignFirstResponder()
                self.cameraTextField.returnKeyType = UIReturnKeyType.Send
                self.cameraTextField.becomeFirstResponder()
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.cameraTextField.resignFirstResponder()
                self.cameraTextField.returnKeyType = UIReturnKeyType.Default
                self.cameraTextField.becomeFirstResponder()
            }
            
            
        }
        

        
    }
    func keyboardWillShow(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification)

    }
    func keyboardWillHide (notification: NSNotification) {
       // print ("keyboardwillhide")
        updateBottomLayoutConstraintWithNotification(notification)
        
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
        bottomLayoutConstraint.constant = CGRectGetMaxY(view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame) + 10
        emoji.constant  = CGRectGetMaxY(view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame) + 25

        //print(CGRectGetMaxY(view.bounds))
        //print(CGRectGetMinY(convertedKeyboardEndFrame))
        if (CGRectGetMaxY(view.bounds) != CGRectGetMinY(convertedKeyboardEndFrame)){
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.bottomScrollView.constant  = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame) +
                self.typingButton.bounds.height + 11 + 10 + 50
                        self.textViewBottom.constant = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame) + self.typingButton.bounds.height + 10 + 11
            }
           
            
        }
        //print (self.typingButton.frame)
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
        print ("start recording")
        recording = true;
        let clipCountString = String(clipCount)
        movieWriter = GPUImageMovieWriter(movieURL: NSURL.fileURLWithPath("\(NSTemporaryDirectory())\(clipCountString).m4v",isDirectory: true), size: view.frame.size)
        filter?.addTarget(movieWriter)

        movieWriter?.encodingLiveVideo = true
        movieWriter?.shouldPassthroughAudio = false
        //movieWriter?.
        //videoCamera?.stopCameraCapture()
        movieWriter?.startRecording()
        
    }
    func stopRecording() {
        print ("stoprecording")
        clipCount++
        recording = false;
        movieWriter?.finishRecording()
        do{
        let files = try fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
        print (files)
        }
        catch {
            print("bad")
        }

       // let files = fileManager.contentsOfDirectoryAtPath(NSTemporaryDirectory(), error: error) as? [String]
       
    }
    func longPressed(sender: UILongPressGestureRecognizer)
    {



        if (sender.state == UIGestureRecognizerState.Began){
                        // Put it somewhere, give it a frame...
            self.typingButton.userInteractionEnabled = false
            panGesture?.enabled = false
            sender.enabled = false
            let blurEffect = UIBlurEffect(style: .Dark)
            let blurOverlay = UIVisualEffectView()
            
            
            let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
            let vibrantOverlay = UIVisualEffectView(effect: vibrancyEffect)
            let overlayScrollView = UIScrollView(frame: CGRectMake(0,0,self.view.bounds.size.width,2*self.view.bounds.height/3))
            print (overlayScrollView.frame)
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
          //  let newLabel = UILabel(frame: CGRectMake(0, scrollView.bounds.size.height + scrollHeight, scrollView.bounds.size.width, textHeight! ))
            for subview in scrollView.subviews{
                if subview is UILabel{
                    let olderLabel = subview as! UILabel
                    let newerLabel = UILabel(frame: CGRectMake(0, scrollHeightOverlay, self.view.bounds.size.width, 25))
                    newerLabel.font = UIFont(name: "Avenir Next", size: 22)
                    newerLabel.textColor = UIColor.whiteColor()
                    newerLabel.text = olderLabel.text
                    newerLabel.numberOfLines = 0
                    newerLabel.sizeToFit()
                    overlayScrollView.addSubview(newerLabel)
                    scrollHeightOverlay = scrollHeightOverlay + newerLabel.bounds.size.height + 10
                }
                
            }
             overlayScrollView.contentSize = CGSizeMake(self.view.bounds.size.width,scrollHeightOverlay)
            vibrantOverlay.contentView.addSubview(overlayScrollView)
            blurOverlay.contentView.addSubview(vibrantOverlay)
            clearAllScroll.transform = CGAffineTransformMakeTranslation(0, 2000)
            quitScrollView.transform = CGAffineTransformMakeTranslation(0, 2000)
            overlayScrollView.transform = CGAffineTransformMakeTranslation (0, -1000)
            clearAllScroll.hidden = false
            quitScrollView.hidden = false

            cameraTextField.resignFirstResponder()
            UIView.animateWithDuration(0.1, animations: {
                blurOverlay.effect = blurEffect
                }, completion: {
                    finished in
                    if (finished){
                        overlayScrollView.flashScrollIndicators()
                        self.view.bringSubviewToFront(self.clearAllScroll)
                        self.view.bringSubviewToFront(self.quitScrollView)
    

                        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 3, options: .CurveEaseInOut, animations: {
                           
                            self.quitScrollView.transform = CGAffineTransformMakeTranslation(0, 0)
                            overlayScrollView.transform = CGAffineTransformMakeTranslation(0, 0)
                            self.view.layoutIfNeeded()
                            }) { _ in
                        }
                        UIView.animateWithDuration(0.5, delay: 0.1, usingSpringWithDamping: 0.85, initialSpringVelocity: 3, options: .CurveEaseInOut, animations: {
                            self.clearAllScroll.transform = CGAffineTransformMakeTranslation(0, 0)
                            
                            }) { _ in
                        }
                    }
            })
            //print("longpressed")
        }
       /* else if (sender.state == UIGestureRecognizerState.Ended){
            print ("longpress ended")
            for subview in self.view.subviews {
                if subview is UIVisualEffectView {
                    subview.removeFromSuperview()
                }
            }
            cameraTextField.becomeFirstResponder()
            
        }*/
    }
    func iPhoneScreenSizes(){
        let bounds = UIScreen.mainScreen().bounds
        let height = bounds.size.height
        
        switch height {
        case 480.0:
            print("iPhone 3,4")
            self.cameraTextField.font = UIFont(name: "AvenirNext-Medium", size: 28.5)
        case 568.0:
            print("iPhone 5")
            self.cameraTextField.font = UIFont(name: "AvenirNext-Medium", size: 28.5)
        case 667.0:
            print("iPhone 6")
            self.cameraTextField.font = UIFont(name: "AvenirNext-Medium", size: 33.5)
        case 736.0:
            print("iPhone 6+")
            self.cameraTextField.font = UIFont(name: "AvenirNext-Medium", size: 37 )
        default:
            print("not an iPhone")
            
        }
        
        
    }



}


