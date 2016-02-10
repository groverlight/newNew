//
//  cameraView.swift
//  
//
//  Created by Aaron Liu on 2/9/16.
//
//

import AVFoundation
import UIKit

class cameraView: UIViewController, UITextFieldDelegate {
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var shouldEdit = true
    @IBOutlet weak var cameraTextField: UITextField!
    @IBOutlet weak var cameraPreview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraTextField.delegate = self
        cameraTextField.becomeFirstResponder()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)){
                if (device.position == AVCaptureDevicePosition.Front) {
                    captureDevice = device as? AVCaptureDevice;
                    if captureDevice != nil {
                        print("Capture device found")
                        beginSession()
                    }
                }
            }
        }

        
        
        
        
    }

    
    override func viewWillAppear(animated: Bool) {
        //print ("appear")
        cameraTextField.becomeFirstResponder()
        shouldEdit = true
        
    }
    

    override func viewWillDisappear(animated: Bool) {

        //print("disappear")
        shouldEdit = false
        cameraTextField.resignFirstResponder()
        
    }
    
    func beginSession() {
        
        let err : NSError? = nil
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch _ {
            print("error: \(err?.localizedDescription)")
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = self.view.layer.frame
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        self.cameraPreview.layer.addSublayer(previewLayer!)
       
        captureSession.startRunning()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {    //delegate method
        //print ("didbeginediting")
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        //print("shouldbegin")
        return true;
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {  //delegate method
        //print("shouldend")
        if (shouldEdit){
            return false
        }
        else{
            return true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //print("didendediting")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        cameraTextField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
    }
    
    func keyboardWillHide (notification: NSNotification) {
    }

    
}


