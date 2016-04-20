//
//  ContactManager.swift
//  SMessenger
//
//  Created by Kostia Girych on 4/14/16.
//  Copyright © 2016 The Three Ways. All rights reserved.
//

import Contacts

//MARK: - ContactManager

class ContactManager: NSObject {
    
    static let sharedInstance = ContactManager()
    
    let cStore = CNContactStore()
    
    private override init() {
        super.init()
    }
}

//MARK: - get contacts from contacts store

extension ContactManager {

    func contacts(complection:([CNContact] -> ())) -> () {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        requestForAccess { [weak self] (accessGranted) -> Void in
            
            if accessGranted {
                
                var contacts = [CNContact]()
                var message:String!
                do{
                    let keys = [CNContactGivenNameKey,
                        CNContactFamilyNameKey,
                        CNContactThumbnailImageDataKey,
                        CNContactPhoneNumbersKey,
                        CNContactEmailAddressesKey,
                        CNContactImageDataKey]
                    let request = CNContactFetchRequest(keysToFetch: keys)
                    
                    try self?.cStore.enumerateContactsWithFetchRequest(request) {
                        contact, stop in
                        contacts.append(contact)
                    }
                }
                catch let err {
                    message = "Unable to fetch contacts."
                    print(err)
                    complection(contacts)
                }
                
                if contacts.count == 0 {
                    message = "No contacts were found matching the given name."
                }
                
                if message != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        MessageManager.sharedInstance.showMessage(message)
                    })
                }
                
                //careful there is background thread
                complection(contacts)
            }
            else {
                let message = "Contacts access not granted"
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    MessageManager.sharedInstance.showMessage(message)
                })
            }
        }
    }
}

//MARK: - get access status contact store

extension ContactManager {
    
    func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
        case .Denied, .NotDetermined:
            cStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            MessageManager.sharedInstance.showMessage(message)
                        })
                    }
                }
            })
        case .Restricted:
            completionHandler(accessGranted: false)
        }
    }
}
