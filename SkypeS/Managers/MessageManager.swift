//
//  MessageManager.swift
//  SkypeS
//
//  Created by Kostia Girych on 4/14/16.
//  Copyright © 2016 The Three Ways. All rights reserved.
//

import UIKit

//MARK: - MessageManager

class MessageManager: NSObject {

    static let sharedInstance = MessageManager()
    
    private override init() {
        super.init()
    }
    
    func showMessage(message: String) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        if let nv = (AppDelegate.getAppDelegate().window?.rootViewController as? UINavigationController) {
            
            let alertController = UIAlertController(title: "Contacts", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            }
            alertController.addAction(dismissAction)
            let pushedViewControllers = nv.viewControllers
            let presentedViewController = pushedViewControllers[pushedViewControllers.count - 1]
            presentedViewController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
