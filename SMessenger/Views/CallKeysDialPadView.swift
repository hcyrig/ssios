//
//  CallKeysDialPadView.swift
//  SMessenger
//
//  Created by Kostia Girych on 4/16/16.
//  Copyright © 2016 The Three Ways. All rights reserved.
//

import FontasticIcons
import JCDialPad

class CallKeysDialPadView: JCDialPad {

    let type = DialpadManagerPads.pad
    
    override var buttons:[AnyObject]! {
        
        get {
            let iView = FIIconView(frame: CGRectMake(0, 0, 65, 65))
            iView.backgroundColor = UIColor.clearColor()
            iView.icon = FIFontAwesomeIcon.phoneIcon()
            iView.padding = 15
            iView.iconColor = UIColor.whiteColor()
            let bButton = JCPadButton(input: DialpadManagerButtonsTypes.kKeyboardViewCallInput.rawValue, iconView: iView, subLabel: "")
            var buttons  = JCDialPad.defaultButtons()
            buttons.append(bButton)
            return buttons as! [JCPadButton]
        }
        set {
            self.buttons = newValue
        }
    }
    
    func setup() {
        
        delegate = self
        formatTextToPhoneNumber = false
        
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
}

//MARK: - JCDialPadDelegate

extension CallKeysDialPadView:JCDialPadDelegate {

    func dialPad(dialPad: JCDialPad!, shouldInsertText text: String!, forButtonPress button: JCPadButton!) -> Bool {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        switch text {
        case DialpadManagerButtonsTypes.kKeyboardViewCallInput.rawValue: DialpadManager.sharedInstance.swithFrom(type,to:DialpadManagerPads.outcoming, animate:true)
        return false
        default:
            return true
        }
    }
}