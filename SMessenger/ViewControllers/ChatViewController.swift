//
//  ChatViewController.swift
//  SMessenger
//
//  Created by Kostia Girych on 5/2/16.
//  Copyright © 2016 The Three Ways. All rights reserved.
//

import Contacts
import UIKit

class ChatViewController: LGChatController {
    
    var test_timer: NSTimer!

    var contact:CNContact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        self.opponentImage = contact?.avatar()
        
        if let name = contact?.fullName() {
            self.title = name
            self.messages = DataManager.sharedInstance.lgpop(name)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.run_tests_data()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    
        self.stop_tests_timer()
    }
}

//MARK: - LGChatControllerDelegate

extension ChatViewController:LGChatControllerDelegate {
    
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

extension ChatViewController {
    
    //interval in 10 secs
    func run_tests_interval() -> Double {
        return Double(10)
    }
    
    func stop_tests_timer() {
    
        if test_timer != nil {
            test_timer.invalidate()
            test_timer = nil
        }
    }
    
    func run_tests_data() {
        
        self.stop_tests_timer()
        
        test_timer = NSTimer.scheduledTimerWithTimeInterval(run_tests_interval(), target: self, selector: #selector(ChatViewController.run_tests_timer_code), userInfo: nil, repeats: true)
    }
    
    func run_tests_timer_code() {
        
        if let message = DataManager.sharedInstance.test_random_message()?.lgchatmessage(LGChatMessage.SentBy.Opponent) {
            self.addNewMessage(message)
        }
    }
}