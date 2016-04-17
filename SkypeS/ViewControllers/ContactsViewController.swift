//
//  ContactsViewController.swift
//  SkypeS
//
//  Created by Kostia Girych on 4/13/16.
//  Copyright © 2016 The Three Ways. All rights reserved.
//

import Contacts
import UIKit

import JCDialPad

class ContactsViewController: UIViewController {

    @IBOutlet weak var table:UITableView!
    @IBOutlet weak var dialPad:UIButton!
    
    var contacts:[CNContact] = []

    var dialPadViewAppear:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        applyRefresh(table)
    }
}

//MARK: - setup refresh control

extension ContactsViewController {

    func applyRefresh(t:UITableView) {
    
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh contacts")
        refreshControl.addTarget(self, action: #selector(ContactsViewController.refreshContacts(_:)), forControlEvents: UIControlEvents.ValueChanged)
        t.addSubview(refreshControl)
        refreshContacts(refreshControl)
    }
    
    func refreshContacts(control:UIRefreshControl) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        
            ContactManager.sharedInstance.contacts { [weak self] (tcontacts) in
                
                self?.contacts.removeAll()
                for contact in tcontacts {
                    self?.contacts.append(contact)
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    control.endRefreshing()
                    self?.table.reloadData()
                })
            }
        }
    }
}

//MARK: - UITableViewDataSource

extension ContactsViewController:UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(ContactTableViewCell.indentifire) as! ContactTableViewCell
        let contact = contacts[indexPath.row]
        cell.configure(contact)
        
        cell.callCallback = { (name, number) in
            
            if !DialpadManager.sharedInstance.isPadShowing {
                DialpadManager.sharedInstance.showPadFrom(self, type: DialpadManagerPads.outcoming, number: number)
            } else {
                DialpadManager.sharedInstance.hidePads()
            }
        }
        
        cell.incommingCallback = { (name, number) in
            
            if !DialpadManager.sharedInstance.isPadShowing {
                DialpadManager.sharedInstance.showPadFrom(self, type: DialpadManagerPads.incoming, number: number)
            } else {
                DialpadManager.sharedInstance.hidePads()
            }
        }
        
        cell.chatCallback = { (name, email) in
            
            let chatController = LGChatController()
            chatController.opponentImage = cell.avatar.image
            chatController.title = name
            let helloMessage = LGChatMessage(content: "Hello skype skeleton messanger!", sentBy: .User)
            chatController.messages = [helloMessage]
            chatController.delegate = self
            self.navigationController?.pushViewController(chatController, animated: true)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}

//MARK: - Actions 

extension ContactsViewController {

    @IBAction func dialPadAction(sender:AnyObject) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
    
        if !DialpadManager.sharedInstance.isPadShowing {
            DialpadManager.sharedInstance.showPadFrom(self, type: DialpadManagerPads.pad, number: nil)
        } else {
            DialpadManager.sharedInstance.hidePads()
        }
    }
}

//MARK: - LGChatControllerDelegate

extension ContactsViewController:LGChatControllerDelegate {
    
    func chatController(chatController: LGChatController, didAddNewMessage message: LGChatMessage) {
        print("Did Add Message: \(message.content)")
    }
    
    func shouldChatController(chatController: LGChatController, addMessage message: LGChatMessage) -> Bool {
        /*
         Use this space to prevent sending a message, or to alter a message.  For example, you might want to hold a message until its successfully uploaded to a server.
         */
        return true
    }
}
