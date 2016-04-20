//
//  MainDialPadView.swift
//  SMessenger
//
//  Created by Kostia Girych on 4/15/16.
//  Copyright © 2016 The Three Ways. All rights reserved.
//

import FontasticIcons
import JCDialPad

class MainDialPadView: JCDialPad {

    let status = UILabel()
    
    let type = DialpadManagerPads.outcoming
    
    var mute:Bool = true {
        didSet {
            layoutSubviews()
        }
    }
    var speaker:Bool = true {
        didSet {
            layoutSubviews()
        }
    }
    
    override var buttons:[AnyObject]! {
        
        get {
            
            let inputs = [DialpadManagerButtonsTypes.kCallingViewMuteInput.rawValue,
                                  DialpadManagerButtonsTypes.kCallingViewKeypadInput.rawValue,
                                  DialpadManagerButtonsTypes.kCallingViewSpeakerInput.rawValue,
                                  DialpadManagerButtonsTypes.kCallingViewHangupInput.rawValue]
            let icons = [mute ? FIFontAwesomeIcon.microphoneIcon() : FIFontAwesomeIcon.microphoneOffIcon(),
                         FIFontAwesomeIcon.thIcon(),
                         speaker ? FIFontAwesomeIcon.volumeDownIcon() : FIFontAwesomeIcon.volumeUpIcon(),
                         FIFontAwesomeIcon.phoneIcon()]
            
            var buttons = [JCPadButton]()
            
            for (index,value) in inputs.enumerate() {
            
                let iView = FIIconView(frame: CGRectMake(0, 0, 65, 65))
                iView.backgroundColor = UIColor.clearColor()
                iView.icon = icons[index]
                iView.padding = 15
                iView.iconColor = UIColor.whiteColor()
                
                let btn = JCPadButton(input: value , iconView: iView, subLabel: "")
                
                if DialpadManagerButtonsTypes.kCallingViewHangupInput.rawValue == value 
                    || DialpadManagerButtonsTypes.kCallingViewKeypadInput.rawValue == value {
                    iView.transform = CGAffineTransformMakeRotation(self.degToRad(Double(90.0)))
                }
                
                if DialpadManagerButtonsTypes.kCallingViewHangupInput.rawValue == value {
                    let btnColor = UIColor(red: 0.987, green: 0.133, blue: 0.146, alpha: 1.000)
                    btn.backgroundColor = btnColor;
                    btn.borderColor     = btnColor;
                }
                buttons.append(btn)
            }
            
            return buttons;
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

extension MainDialPadView:JCDialPadDelegate {
    
    func dialPad(dialPad: JCDialPad!, shouldInsertText text: String!, forButtonPress button: JCPadButton!) -> Bool {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        switch text {
        case DialpadManagerButtonsTypes.kCallingViewMuteInput.rawValue: mute = !mute
        case DialpadManagerButtonsTypes.kCallingViewKeypadInput.rawValue: DialpadManager.sharedInstance.swithFrom(type,to:DialpadManagerPads.inpad, animate:true)
        case DialpadManagerButtonsTypes.kCallingViewSpeakerInput.rawValue: speaker = !speaker
        case DialpadManagerButtonsTypes.kCallingViewHangupInput.rawValue: DialpadManager.sharedInstance.swithFrom(type,to:DialpadManagerPads.empty, animate:true)
        default:
            return false
        }
        return false
    }
}
