//
//  WindowExtension.swift
//  BackMenu
//
//  Created by Guy Kahlon on 1/25/15.
//  Copyright (c) 2015 GuyKahlon. All rights reserved.
//

import UIKit
var frontWindow: UIWindow?
private var beganOrigin = CGPoint()

private let kHeaderHeight: CGFloat = 64
private let kTransform: CGFloat = 0.9
private let kAlphe: CGFloat = 0.4
private let kAnimationDuration: NSTimeInterval = 0.3
private let kstatusBarStyle = UIStatusBarStyle.LightContent

var tapGesture : UITapGestureRecognizer?
var panGesture : UIPanGestureRecognizer? = UIPanGestureRecognizer()
let backWindow:UIWindow? = UIApplication.sharedApplication().delegate?.window!

extension UIWindow{
    
    func stopSwipeToOpenMenu(){
        
        if let pan = panGesture{
            removeGestureRecognizer(pan)
        }
        if let tap = tapGesture{
            removeGestureRecognizer(tap)
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func startSwipeToOpenMenu(){

        panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        addGestureRecognizer(panGesture!);
        

    }

    func handlePanGesture(panGesture : UIPanGestureRecognizer){
        
        let translation:CGPoint = panGesture.translationInView(self);
        
        switch (panGesture.state){
        case .Began:
            //print("began")

            beganOrigin = frame.origin;
            break;
        case .Changed:
            
            //print(frontWindow?.subviews[(frontWindow?.subviews.endIndex)!-1])
            for subview in (frontWindow?.subviews)!{
                if (subview is UIVisualEffectView)
                {
                    frontWindow?.bringSubviewToFront(subview)
                    subview.alpha = frame.origin.y/300
                    //print (subview)
                }
            }
            //frontWindow?.subviews[0].alpha = frame.origin.y/300;
            let val = (frame.origin.y * ((1 - kTransform) / UIScreen.mainScreen().bounds.height)) + kTransform;
            let t1 = CATransform3DScale(CATransform3DIdentity, val , val , 1);
            
            let valAlphe = (frame.origin.y * ((1 - kAlphe) / UIScreen.mainScreen().bounds.height)) + kAlphe;
            
            if beganOrigin.y + translation.y >= -kHeaderHeight{
                
                self.transform = CGAffineTransformMakeTranslation(0, translation.y);
                backWindow?.rootViewController?.view.layer.transform = t1;
                backWindow?.rootViewController?.view.alpha = valAlphe;
            }
 
        case .Ended, .Cancelled:
           // print ("ended")
            var finalOrigin:CGPoint = CGPointZero;
            var finalTransform: CATransform3D = CATransform3DIdentity
            var alpha: CGFloat = 1.0;
            if frame.origin.y >= 70 {
                finalOrigin.y = CGRectGetHeight(UIScreen.mainScreen().bounds) - kHeaderHeight;
                addTapGestureToClose()
                for subview in (frontWindow?.subviews)!{
                    if (subview is UIVisualEffectView)
                    {
                        frontWindow?.bringSubviewToFront(subview)
                        subview.alpha = 1
                        //print (subview)
                    }
                }
                frontWindow?.rootViewController?.viewWillDisappear(false)
                backWindow?.rootViewController?.viewDidAppear(false)

            }
            else{
                finalTransform = CATransform3DScale(finalTransform, kTransform , kTransform , 1);
                alpha = kAlphe
               // statusBarStyle = UIStatusBarStyle.Default
               
                removeTapGestureToClose()
                for subview in (frontWindow?.subviews)!{
                    if (subview is UIVisualEffectView)
                    {
                        frontWindow?.bringSubviewToFront(subview)
                        subview.alpha = 0
                        //print (subview)
                    }
                }
                frontWindow?.rootViewController?.viewWillAppear(false)
                

            }
            
            var finalFrame = frame;
            finalFrame.origin = finalOrigin;

            UIView.animateWithDuration(kAnimationDuration, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                
                backWindow?.rootViewController?.view.layer.transform = finalTransform;
                backWindow?.rootViewController?.view.alpha = alpha;
                
                self.transform = CGAffineTransformIdentity;
                self.frame = finalFrame;
               UIApplication.sharedApplication().statusBarStyle = .LightContent
                }, completion: { (finished: Bool) -> Void in
            })
        default:
            print("Unknown panGesture state")
        }
    }
    
    func handleTapGesture(panGesture : UIPanGestureRecognizer){
        close()
    }


    // MARK: Private methids
    private func close(){
        //print ("close")
        frontWindow?.rootViewController?.viewWillAppear(false)
        for subview in (frontWindow?.subviews)!{
            if (subview is UIVisualEffectView)
            {
                frontWindow?.bringSubviewToFront(subview)
                subview.alpha = 0
                //print (subview)
            }
        }
        // frontWindow?.rootViewController?.view.subviews[2]
        UIView.animateWithDuration(kAnimationDuration + 0.1, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
            
            backWindow?.rootViewController?.view.layer.transform = CATransform3DScale(CATransform3DIdentity, kTransform , kTransform , 1);
            backWindow?.rootViewController?.view.alpha = 0
            
            self.transform = CGAffineTransformIdentity;
            
            self.frame = UIScreen.mainScreen().bounds;
            }, completion: { (finished: Bool) -> Void in
                frontWindow?.rootViewController?.viewDidAppear(false)
                self.removeTapGestureToClose()
        })
    }
    
    // MARK: Tap Gesture
    private func addTapGestureToClose(){
       // print ("addtap")
        if let tap = tapGesture{
            addGestureRecognizer(tap)
        }
        else{
            tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
            addGestureRecognizer(tapGesture!)
        }
    }
    
    private func removeTapGestureToClose(){
            //print ("removetap")
            if let tap = tapGesture{
            removeGestureRecognizer(tap)
        }
    }
}


