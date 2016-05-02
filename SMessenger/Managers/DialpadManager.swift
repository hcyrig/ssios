//
//  DialpadManager.swift
//  SMessenger
//
//  Created by Kostia Girych on 4/15/16.
//  Copyright © 2016 The Three Ways. All rights reserved.
//

import UIKit

import FontasticIcons
import JCDialPad

enum DialpadManagerButtonsTypes:String {
    
    case kCallingViewMuteInput = "M"
    case kCallingViewKeypadInput = "K"
    case kCallingViewSpeakerInput = "S"
    case kCallingViewAcceptInput = "A"
    case kCallingViewIgnoreInput = "I"
    case kCallingViewHangupInput = "H"
    case kKeyboardViewBackInput = "B"
    case kKeyboardViewCallInput = "C"
}

enum DialpadManagerPads:String {

    case outcoming = "outcoming"
    case incoming = "incoming"
    case inpad = "inpad"
    case pad = "pad"
    case empty = "empty"
}

//MARK: - Implement delegate if you wonna to have more inforamation about pad behaviour
protocol DialpadManagerDelegate : class {
    
    func dialPadDidOpen(type:DialpadManagerPads, controller:UIViewController) -> ()
    func dialPadDidSwithed(pad:JCDialPad, controller:UIViewController) -> ()
    func dialPadDidClose(type:DialpadManagerPads, controller:UIViewController) -> ()
}

class DialpadManager: NSObject {

    static let sharedInstance = DialpadManager()
    
    lazy var vc:UIViewController = {
        
        let vct = UIViewController()
        vct.view.frame = AppDelegate.getAppDelegate().window!.bounds
        return vct
    }()
    
    let outcoming = MainDialPadView()
    let incoming = IncomingDialPadView()
    let inpad = KeysDialPadView()
    let pad = CallKeysDialPadView()
    
    weak var delegate:DialpadManagerDelegate?
    
    var pads:[JCDialPad] {
        return [outcoming, incoming, inpad, pad]
    }
    
    var isPadShowing = false {
        
        didSet {
            if isPadShowing {
                vc.parentViewController?.navigationController?.navigationBarHidden = true
            } else {
                vc.parentViewController?.navigationController?.navigationBarHidden = false
            }
        }
    }
    
    private override init() {
        super.init()
    }
    
    private func padByType(type:DialpadManagerPads) -> JCDialPad? {
        
        switch type {
        case .outcoming: return outcoming
        case .incoming: return incoming
        case .empty: return nil
        case .pad: return pad
        case .inpad: return inpad
        }
    }
    
    func showPadFrom(parentVC:UIViewController, type:DialpadManagerPads, number:String?) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        if isPadShowing {
            return
        }
        
        if type == DialpadManagerPads.empty {
            return
        } else if type == DialpadManagerPads.outcoming && number == nil {
            return
        } else if type == DialpadManagerPads.incoming && number == nil {
            return
        }

        setupPads(vc)
        padByType(type)?.hidden = false
        padByType(type)?.rawText = ""
        padByType(type)?.digitsTextField.text = number
        
        parentVC.addChildViewController(vc)
        vc.didMoveToParentViewController(parentVC)
        parentVC.view.addSubview(vc.view)
        
        isPadShowing = true
        
        self.delegate?.dialPadDidOpen(type, controller: vc)
    }
    
    func hidePads(type:DialpadManagerPads = DialpadManagerPads.empty) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        if !isPadShowing {
            return
        }
        isPadShowing = false
        
        vc.removeFromParentViewController()
        vc.view.removeFromSuperview()
        
        for pad in pads {
            pad.hidden = true
        }
        
        self.delegate?.dialPadDidClose(type,controller: vc)
    }
    
    private func setupPads(vc:UIViewController) {
        
        for pad in pads {
            pad.frame = vc.view.bounds
            vc.view.addSubview(pad)
            pad.hidden = true
        }
        
        outcoming.setup()
        incoming.setup()
        inpad.setup()
        pad.setup()
    }
}

//MARK: - JCDialPadDelegate

extension DialpadManager:JCDialPadDelegate {
    
    func swithFrom(type:DialpadManagerPads,to:DialpadManagerPads, animate:Bool) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        if to == DialpadManagerPads.incoming {
            swithToPad(vc, pad: incoming, animated: animate)
        }
        
        if to == DialpadManagerPads.outcoming {
            
            if padByType(type)?.digitsTextField.text != nil && padByType(type)?.digitsTextField.text != "" {
                outcoming.digitsTextField.text = padByType(type)?.digitsTextField.text
                outcoming.handle()
            }
            swithToPad(vc, pad: outcoming, animated: animate)
        }
        
        if to == DialpadManagerPads.inpad {
            inpad.rawText = ""
            inpad.digitsTextField.text = nil
            swithToPad(vc, pad: inpad, animated: animate)
        }
        
        if to == DialpadManagerPads.empty {
            hidePads(type)
        }
    }
    
    func swithToPad(vc:UIViewController?, pad:JCDialPad, animated:Bool) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        if vc == nil {
            return
        }
        
        if pad.hidden {
            pad.alpha = 0.0
        }
        pad.hidden = false
        
        vc?.view.bringSubviewToFront(pad)

        UIView.animateWithDuration(0.3 * Double(animated.hashValue), animations: {
            
            pad.alpha = 1.0
            
        }) { (state) in
            
            for p in self.pads {
                if p != pad {
                    p.hidden = true;
                }
            }
            
            self.delegate?.dialPadDidSwithed(pad, controller: vc!)
        }
    }
}


//MARK: - rotation handler

extension DialpadManager {
    
    func subsctibeToRoration() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DialpadManager.rotationHandler), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func unsubscribeToRotation() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func rotationHandler(orientation:UIDeviceOrientation) {
        
        if (UIDeviceOrientationIsLandscape(orientation)) {
            print("landscape")
        }
        
        if (UIDeviceOrientationIsPortrait(orientation)) {
            print("Portrait")
        }
        
        if DialpadManager.sharedInstance.isPadShowing {
            
            for pad in pads {
                //beacerfull there is H:W frame not W:H original frame size
                pad.frame = CGRect(x: 0.0, y: 0.0, width: vc.view.frame.height, height: vc.view.frame.width)
                pad.layoutIfNeeded()
            }
        }
    }
}
