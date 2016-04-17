//
//  ContactTableViewCell.swift
//  SkypeS
//
//  Created by Kostia Girych on 4/14/16.
//  Copyright © 2016 The Three Ways. All rights reserved.
//

import Contacts
import UIKit

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var email:UILabel!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var phone:UILabel!
    @IBOutlet weak var avatar:UIImageView!
    @IBOutlet weak var call:UIButton!
    @IBOutlet weak var chat:UIButton!
    @IBOutlet weak var incomming:UIButton!
    
    var callCallback:((name:String, number:String) -> ())?
    var chatCallback:((name:String, email:String) -> ())?
    var incommingCallback:((name:String, number:String) -> ())?
    
    static let indentifire = "ContactTableViewCell"
    
    func configure(c:CNContact) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        // Set the full name info.
        name.text = "\(c.givenName) \(c.familyName)"

        // Set the contact image.
        if let imageData = c.thumbnailImageData {
            avatar.image = UIImage(data: imageData)
        } else if let imageData = c.imageData {
            avatar.image = UIImage(data: imageData)
        } else {
            avatar.image = UIImage(named: "avatar")
        }
        
        // Set the contact's email address.
        var homeEmailAddress: [String] = []
        for emailAddress in c.emailAddresses {
            homeEmailAddress.append(emailAddress.value as! String)
        }
        if homeEmailAddress.count != 0 {
            email.text = homeEmailAddress.joinWithSeparator(", ")
        }
        else {
            email.text = "Not available email"
        }
        
        // Set the contact's phone number.
        var phoneNumbers: [String] = []
        for number in c.phoneNumbers {
            let pN = number.value as! CNPhoneNumber
            phoneNumbers.append(pN.stringValue)
        }
        if phoneNumbers.count != 0 {
            phone.text = phoneNumbers.joinWithSeparator(", ")
        }
        else {
            phone.text = "Not available number"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatar.layer.cornerRadius = avatar.bounds.width / 2.0
    }
}

//MARK: - Actions

extension ContactTableViewCell {

    @IBAction func callAction(sender:AnyObject) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        if let p = phone.text, let n = name.text {
            
            let numbers = p.componentsSeparatedByString(",")
            if (numbers.count > 0 && numbers.first != nil) {
                callCallback?(name:n, number:numbers.first!)
            }
        }
    }

    @IBAction func incommingAction(sender:AnyObject) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        if let p = phone.text, let n = name.text {
            
            let numbers = p.componentsSeparatedByString(",")
            if (numbers.count > 0 && numbers.first != nil) {
                incommingCallback?(name:n, number:p)
            }
        }
    }

    @IBAction func chatAction(sender:AnyObject) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        if let e = email.text, let n = name.text {
            chatCallback?(name:n, email:e)
        }
    }
}
