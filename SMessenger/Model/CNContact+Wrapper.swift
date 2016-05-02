//
//  CNContact+Wrapper.swift
//  SMessenger
//
//  Created by Kostia Girych on 5/2/16.
//  Copyright © 2016 The Three Ways. All rights reserved.
//

import Contacts
import UIKit

extension CNContact {

    // Generate full contact's name.
    func fullName() -> String {
        return "\(self.givenName) \(self.familyName)"
    }
    
    // Get emails from current contact.
    func emails() -> String {
        
        if nemails().count != 0 {
            return nemails().joinWithSeparator(", ")
        }
        return "Not available email"
    }

    // Get phones from current contact.
    func phones() -> String {
        
        if nphones().count != 0 {
            return nphones().joinWithSeparator(", ")
        }
        return  "Not available number"
    }
    
    func avatar() -> UIImage? {
        
        if let imageData = self.thumbnailImageData {
            return UIImage(data: imageData)
        } else if let imageData = self.imageData {
            return UIImage(data: imageData)
        } else {
            return UIImage(named: "avatar")
        }
    }
    
    private func nemails() -> [String] {
        
        var homeEmailAddress: [String] = []
        for emailAddress in self.emailAddresses {
            homeEmailAddress.append(emailAddress.value as! String)
        }
        return homeEmailAddress
    }
    
    private func nphones() -> [String] {
        
        var phoneNumbers: [String] = []
        for number in self.phoneNumbers {
            let pN = number.value as! CNPhoneNumber
            phoneNumbers.append(pN.stringValue)
        }
        return phoneNumbers
    }
}
