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

var frontWindow: UIWindow?
var arrayofText: NSMutableArray = []
class cameraView: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var buttonSpring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
    var buttonScale = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
    var recording = false
    var previousRect = CGRectZero
    var imagePicker: UIImagePickerController! = UIImagePickerController()
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var typingLabel: UILabel!
    @IBOutlet weak var typingButton: UIButton!
    @IBAction func typingButtonFunc(sender: AnyObject) {
        if (cameraTextField.text.characters.count == 0){
            //add spring animation
            typingButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
            typingButton.pop_addAnimation(buttonSpring, forKey: "shake")
        }
        else{
            //begin video phase
            
            cameraTextField.resignFirstResponder()
            if (recording == false) {
                print (cameraTextField.text)
                arrayofText.addObject(cameraTextField.text)
               // print ("start recording")
                self.startRecording()
                typingButton.pop_addAnimation(buttonScale, forKey: "scale")
            } else {
                //print ("stop recording")

                //self.stopRecording()
            }

        }
    }
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var shouldEdit = true
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var cameraTextField: UITextView!
    var videoCamera:GPUImageVideoCamera?
    var filter:GPUImageMissEtikateFilter?
    var filteredImage: GPUImageView?
    var movieWriter: GPUImageMovieWriter?
    var clipCount = 1
    var fileManager: NSFileManager? = NSFileManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("cameraView laoded")
        buttonScale.duration =   2;
        buttonScale.toValue = NSValue(CGPoint: CGPointMake(2, 2))
        buttonScale.completionBlock = {(animation, finished) in
            //Code goes here
            if (finished){
                //print("animation done")
                self.stopRecording()
                self.cameraTextField.text.removeAll()
                self.cameraTextField.returnKeyType = UIReturnKeyType.Go
                self.cameraTextField.becomeFirstResponder()
                self.typingButton.pop_addAnimation(self.buttonSpring, forKey: "shake")
                
                
            }
        }
        buttonSpring.toValue = NSValue(CGPoint: CGPointMake(1, 1))
        buttonSpring.velocity = NSValue(CGPoint: CGPointMake(6, 6))
        buttonSpring.springBounciness = 20.0
        
        cameraTextField.delegate = self
        
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
         //[self performSelector:@selector(showcamera) withObject:nil afterDelay:0.3];
        
        //typingButton.blur(blurRadius: 2)
        
        if (UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front)){
           // self.createImagePicker()
            
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
        
     
    }
    override func viewWillAppear(animated: Bool) {
      // print ("appear")
       // print ("view will appear deleting files")
        //print (files)
        do{
            let files = try fileManager?.contentsOfDirectoryAtPath(NSTemporaryDirectory())
            for file:NSString in files!{
                try fileManager?.removeItemAtPath("\(NSTemporaryDirectory())\(file)")
            }
           // print (files)
            if (files?.count == 0){
                clipCount = 1
            }
            
        }
        catch {
            print("bad")
        }

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
       // print("disappear")
        shouldEdit = false
        //cameraTextField.removeObserver(self, forKeyPath: "contentSize")
        cameraTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n" && cameraTextField.returnKeyType == UIReturnKeyType.Go){
           // print ("go")
            //let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("sendView") as! sendView
            cameraTextField.resignFirstResponder()
            //self.view.endEditing(true)
            self.presentViewController(vc, animated: false, completion: nil)
            //self.performSegueWithIdentifier("goSend", sender: self)
            return false
        }
        else if (text == "\n" && cameraTextField.returnKeyType != UIReturnKeyType.Go){
            return false
        }
        if(cameraTextField.text.characters.count - range.length + text.characters.count > 70){
            //print ("too many")
            return false;
        }
        return true
    }
    func textViewDidChange(textView: UITextView) {


        
    }
    func keyboardWillShow(notification: NSNotification) {
        //print ("keyboardwillshow")
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
        //print ("start recording")
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
        //print ("stoprecording")
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
    
    /*func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("Got a video")
        
        if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {
            // Save video to the main photo album
            print(pickedVideo)
            //arrayofText .addObject(pickedVideo)
            // Save the video to the app directory so we can play it later
            let videoData = NSData(contentsOfURL: pickedVideo)
            let paths = NSSearchPathForDirectoriesInDomains(
                NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentsDirectory: AnyObject = paths[0]
            let dataPath = documentsDirectory.stringByAppendingPathComponent("")
            videoData?.writeToFile(dataPath, atomically: false)
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
        
        imagePicker.dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user saves an video
        })
    }*/


}


