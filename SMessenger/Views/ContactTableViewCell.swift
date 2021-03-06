//
//  ContactTableViewCell.swift
//  SMessenger
//
//  Created by Kostia Girych on 4/14/16.
//  Copyright © 2016 The Three Ways. All rights reserved.
//

import Contacts
import UIKit

class ContactTableViewCell: UITableViewCell {
    
//    @IBOutlet weak var email:UILabel!
    @IBOutlet weak var name:UILabel!
//    @IBOutlet weak var phone:UILabel!
    @IBOutlet weak var avatar:UIImageView!
    @IBOutlet weak var call:UIButton!
    @IBOutlet weak var chat:UIButton!
//    @IBOutlet weak var incomming:UIButton!
    
    var callCallback:((cell:ContactTableViewCell) -> ())?
    var chatCallback:((cell:ContactTableViewCell) -> ())?
//    var incommingCallback:((cell:ContactTableViewCell) -> ())?
    
    static let indentifire = "ContactTableViewCell"
    
    func configure(c:CNContact) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        // Set the full name info.
        name.text = c.fullName()

        // Set the contact image.
        avatar.image = c.avatar()
        
//        // Set the contact's email address.
//        var homeEmailAddress: [String] = []
//        for emailAddress in c.emailAddresses {
//            homeEmailAddress.append(emailAddress.value as! String)
//        }
//        if homeEmailAddress.count != 0 {
//            email.text = homeEmailAddress.joinWithSeparator(", ")
//        }
//        else {
//            email.text = "Not available email"
//        }
//        
//        // Set the contact's phone number.
//        var phoneNumbers: [String] = []
//        for number in c.phoneNumbers {
//            let pN = number.value as! CNPhoneNumber
//            phoneNumbers.append(pN.stringValue)
//        }
//        if phoneNumbers.count != 0 {
//            phone.text = phoneNumbers.joinWithSeparator(", ")
//        }
//        else {
//            phone.text = "Not available number"
//        }
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
        
        callCallback?(cell: self)
    }

//    @IBAction func incommingAction(sender:AnyObject) {
//        #if DEBUG
//            print("This is on line \(#line) of \(#function)")
//        #endif
//
//    }

    @IBAction func chatAction(sender:AnyObject) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        chatCallback?(cell: self)
    }
}
