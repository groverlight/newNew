//
//  cameraView.swift
//  
//
//  Created by Aaron Liu on 2/9/16.
//
//

import AVFoundation
import UIKit
import MobileCoreServices
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

                print ("start recording")
                self.startRecording()
                typingButton.pop_addAnimation(buttonScale, forKey: "scale")
            } else {
                print ("stop recording")

                self.stopRecording()            }

        }
    }
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var shouldEdit = true
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var cameraTextField: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //set the pop animations
        buttonScale.duration =   2;

        buttonScale.toValue = NSValue(CGPoint: CGPointMake(2, 2))
        buttonScale.completionBlock = {(animation, finished) in
            //Code goes here
            if (finished){
                print("animation done")
                self.stopRecording()
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
        

        self.createImagePicker()
        
     
    }
    override func viewWillAppear(animated: Bool) {
  
        super.viewWillAppear(animated)
         cameraTextField.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
         cameraTextField.delegate = self
         cameraTextField.becomeFirstResponder()
         shouldEdit = true
        
    }
    override func viewDidAppear(animated: Bool) {
        //print("camera view did appear")
        super.viewDidAppear(animated)
        let theRect = imagePicker.view.frame
        cameraPreview?.frame = theRect
        //imagePicker.cameraOverlayView = cameraPreview
        //self.presentViewController(imagePicker, animated: animated, completion: nil)
    }
    override func viewWillDisappear(animated: Bool) {

        //print("disappear")
        shouldEdit = false
        //cameraTextField.removeObserver(self, forKeyPath: "contentSize")
        cameraTextField.resignFirstResponder()
    }
    func textFieldDidBeginEditing(textField: UITextField) {    //delegate method
        //print ("didbeginediting")
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        print("shouldbegin")
            return true
    }
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {  //delegate method
        //print("shouldend")
        return true
    }
    func textFieldDidEndEditing(textField: UITextField) {
        //print("didendediting")
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        cameraTextField.resignFirstResponder()
        print("shouldreturn")
        return true
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(cameraTextField.text.characters.count - range.length + text.characters.count > 70){
            //print ("too many")
            return false;
        }
        return true
    }
    func textViewDidChange(textView: UITextView) {


        
    }
    func keyboardWillShow(notification: NSNotification) {

        updateBottomLayoutConstraintWithNotification(notification)

    }
    func keyboardWillHide (notification: NSNotification) {
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
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.mediaTypes = [kUTTypeMovie as String]
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
        self.view.insertSubview(imagePicker.view, atIndex: 0)
    }
    func toggleVideoRecording() {
        
    }
    func startRecording() {
        recording = true;
        imagePicker.startVideoCapture()
        
    }
    func stopRecording() {
        recording = false;
        imagePicker.stopVideoCapture()
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
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
    }


}


