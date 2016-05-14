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
    @IBOutlet weak var searchBar:UISearchBar!
    
    var contacts:[CNContact] = []
    var fcontacts:[CNContact] = []
    var searchActive:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        applyRefresh(table)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        DialpadManager.sharedInstance.subsctibeToRoration()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        DialpadManager.sharedInstance.unsubscribeToRotation()
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

    func contactBy(cell:ContactTableViewCell) -> CNContact? {
        
        if let index = self.table.indexPathForCell(cell) {
            
            var tcontacts = fcontacts
            if !searchActive {
                tcontacts = contacts
            }
            
            if (tcontacts.count > index.row) {
                return tcontacts[index.row]
            }
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(ContactTableViewCell.indentifire) as! ContactTableViewCell
        
        var tcontacts = fcontacts
        if !searchActive {
            tcontacts = contacts
        }
        
        let contact = tcontacts[indexPath.row]
        cell.configure(contact)
        
        cell.callCallback = { [weak self] cell in
            
            if let contact = self?.contactBy(cell), let weak = self {
                
                if !DialpadManager.sharedInstance.isPadShowing {
                    DialpadManager.sharedInstance.showPadFrom(weak, type: DialpadManagerPads.outcoming, number: contact.phones())
                } else {
                    DialpadManager.sharedInstance.hidePads()
                }
            }
        }
    
        cell.chatCallback = { [weak self] cell in
            
            if let contact = self?.contactBy(cell), let weak = self {
                
                let chat = ChatViewController()
                chat.contact = contact
                weak.navigationController?.pushViewController(chat, animated: true)
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchActive {
           return fcontacts.count
        }
        return contacts.count
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}

//MARK: - UIScrollViewDelegate

extension ContactsViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.endEditing(true)
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
    
    @IBAction func dialPadIncomingAction(sender:AnyObject) {
        #if DEBUG
            print("This is on line \(#line) of \(#function)")
        #endif
        
        if !DialpadManager.sharedInstance.isPadShowing {
            DialpadManager.sharedInstance.showPadFrom(self, type: DialpadManagerPads.incoming, number: "+38308042830480")
        } else {
            DialpadManager.sharedInstance.hidePads()
        }
    }
}

//MARK: - UISearchBarDelegate

extension ContactsViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        fcontacts = contacts.filter({ contact -> Bool in
            let tmp: NSString = contact.fullName()
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        
        if searchText == "" {
            fcontacts = contacts
        }
        self.table.reloadData()
    }
}
