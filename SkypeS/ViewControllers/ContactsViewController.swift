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
    lazy var dialPadView:JCDialPad = {
    
        let dialpad = JCDialPad(frame:self.view.bounds)
        dialpad.buttons = JCDialPad.defaultButtons()
        dialpad.digitsTextField.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.5)
        for button in dialpad.buttons {
            let b = button as! JCPadButton
            b.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.5)
            b.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.5)
        }
        dialpad.delegate = self
        dialpad.backgroundColor = UIColor.whiteColor()
        return dialpad
    }()
    
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
        
        }
        
        cell.incommingCallback = { (name, number) in
            
        }
        
        cell.chatCallback = { (name, email) in
            
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
    
        if !dialPadViewAppear {
            view.addSubview(dialPadView)
            dialPadViewAppear = true
        } else {
            dialPadView.removeFromSuperview()
            dialPadViewAppear = false
        }
    }
}

extension ContactsViewController:JCDialPadDelegate {

    func dialPad(dialPad: JCDialPad!, shouldInsertText text: String!, forButtonPress button: JCPadButton!) -> Bool {
        return true
    }
}
