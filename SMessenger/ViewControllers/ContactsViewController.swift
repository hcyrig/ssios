//
//  ContactsViewController.swift
//  SMessenger
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
    
    var test_timer: NSTimer!
    var chat:LGChatController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        applyRefresh(table)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if test_timer != nil {
            test_timer.invalidate()
            test_timer = nil
        }
        
        if chat != nil {
            chat = nil
        }
    }
}

//MARK: - setup refresh control

extension ContactsViewController {

    func applyRefresh(t:UITableView) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
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
        
        cell.chatCallback = { [weak self] (name, email) in
            
            self?.chat = LGChatController()
            self?.chat!.opponentImage = cell.avatar.image
            self?.chat!.title = name
            self?.chat!.messages = DataManager.sharedInstance.lgpop(name)
            self?.chat!.delegate = self
            self!.navigationController?.pushViewController((self?.chat)!, animated: true)
            self?.run_tests_data()
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
    
    func chatController(chatController: LGChatController, didAddNewMessage messaget: LGChatMessage) {
        
        print("Did Add Message: \(messaget.content)")
        if let name = chatController.title {
        
            var messages = DataManager.sharedInstance.pop(name)
            if messages == nil {
                messages = [Message]()
            }
            messages?.append(Message(text: messaget.content, by: messaget.sentByString, time: "\(messaget.timeStamp)"))
            DataManager.sharedInstance.push(messages, by: chatController.title!)
        }
    }
    
    func shouldChatController(chatController: LGChatController, addMessage message: LGChatMessage) -> Bool {
        /*
         Use this space to prevent sending a message, or to alter a message.  For example, you might want to hold a message until its successfully uploaded to a server.
         */
        return true
    }
}

//MARK: - a timer for test data by 10 sec

extension ContactsViewController {

    //interval in 10 secs
    func run_tests_interval() -> Double {
        return Double(10)
    }
    
    func run_tests_data() {
        
        if test_timer != nil {
            test_timer.invalidate()
            test_timer = nil
        }
        
        test_timer = NSTimer.scheduledTimerWithTimeInterval(run_tests_interval(), target: self, selector: #selector(ContactsViewController.run_tests_timer_code), userInfo: nil, repeats: true)
    }
    
    func run_tests_timer_code() {
        
        if let message = DataManager.sharedInstance.test_random_message()?.lgchatmessage(LGChatMessage.SentBy.Opponent) {
            chat?.addNewMessage(message)
        }
    }
}
