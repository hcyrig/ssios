//
//  IncomingDialPadView.swift
//  SMessenger
//
//  Created by Kostia Girych on 4/15/16.
//  Copyright © 2016 The Three Ways. All rights reserved.
//

import FontasticIcons
import JCDialPad

class IncomingDialPadView: JCDialPad {
    
    let status = UILabel()
    
    let type = DialpadManagerPads.incoming
    
    override var buttons:[AnyObject]! {
        
        get {
            let inputs = [DialpadManagerButtonsTypes.kCallingViewAcceptInput.rawValue,
                                  DialpadManagerButtonsTypes.kCallingViewIgnoreInput.rawValue,
                                  DialpadManagerButtonsTypes.kCallingViewHangupInput.rawValue]
            let icons = [FIFontAwesomeIcon.phoneIcon(),
                         FIEntypoIcon.muteIcon(),
                         FIFontAwesomeIcon.phoneIcon()]
            
            var buttons = [JCPadButton]()
            for (index,value) in inputs.enumerate() {
            
                let iView = FIIconView(frame: CGRectMake(0, 0, 65, 65))
                iView.backgroundColor = UIColor.clearColor()
                iView.icon = icons[index]
                iView.padding = 15
                iView.iconColor = UIColor.whiteColor()
                
                let btn = JCPadButton(input: value, iconView: iView, subLabel: "")
                var btnColor = UIColor(red: 0.488, green: 0.478, blue: 0.504, alpha: 1.000)
                
                if DialpadManagerButtonsTypes.kCallingViewAcceptInput.rawValue == value {
                    btnColor = UIColor(red: 0.261, green: 0.837, blue: 0.319, alpha: 1.000)
                }
                if DialpadManagerButtonsTypes.kCallingViewHangupInput.rawValue == value {
                    btnColor = UIColor(red: 0.987, green: 0.133, blue: 0.146, alpha: 1.000)
                    iView.transform = CGAffineTransformMakeRotation(self.degToRad(Double(90.0)))
                }
                
                btn.backgroundColor = btnColor;
                btn.borderColor     = btnColor;
                buttons.append(btn)
            }
            return buttons
        }
        set {
            self.buttons = newValue
        }
    }
    
    private func degToRad(deg:Double) -> CGFloat {
        return CGFloat(deg * M_PI / 180)
    }
    
    func setup() {
        
        delegate = self
        showDeleteButton = false
        //setupStatus()
        
        //take snapshot of root view and set as background:
        if let nv = (AppDelegate.getAppDelegate().window?.rootViewController as? UINavigationController) {
            
            let pushedViewControllers = nv.viewControllers
            let presentedViewController:UIViewController = pushedViewControllers[pushedViewControllers.count - 1]
            UIGraphicsBeginImageContext(presentedViewController.view.size())
            presentedViewController.view.drawViewHierarchyInRect(presentedViewController.view.bounds, afterScreenUpdates: true)
            let image =  UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            
            let imageView = UIImageView(image: image)
            imageView.contentMode = .ScaleAspectFill
            backgroundView = imageView
        }
    }
    
    func setupStatus() {
        
        status.frame = CGRect(x: CGFloat(0.0), y: digitsTextField.bottom(), width: width(), height: CGFloat(24.0))
        status.textColor = UIColor(white: 1.0, alpha: 0.8)
        status.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        status.textAlignment = .Center
        status.userInteractionEnabled = false
        addSubview(status)
    }
}

//MARK: - JCDialPadDelegate

extension IncomingDialPadView:JCDialPadDelegate {
    
    func dialPad(dialPad: JCDialPad!, shouldInsertText text: String!, forButtonPress button: JCPadButton!) -> Bool {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        switch text {
        case DialpadManagerButtonsTypes.kCallingViewAcceptInput.rawValue: DialpadManager.sharedInstance.swithFrom(type,to:DialpadManagerPads.outcoming, animate:true)
            return false
        case DialpadManagerButtonsTypes.kCallingViewIgnoreInput.rawValue: DialpadManager.sharedInstance.swithFrom(type,to:DialpadManagerPads.empty, animate:true)
            return false
        case DialpadManagerButtonsTypes.kCallingViewHangupInput.rawValue: DialpadManager.sharedInstance.swithFrom(type,to:DialpadManagerPads.empty, animate:true)
            return false
        default:
            return true
        }
    }
}
