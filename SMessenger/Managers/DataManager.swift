//
//  DataManager.swift
//  SMessenger
//
//  Created by Kostia Girych on 4/20/16.
//  Copyright © 2016 The Three Ways. All rights reserved.
//

import UIKit

//MARK: - Main data singelton

class DataManager: NSObject {
    
    static let sharedInstance = DataManager()
    
    private override init() {
        super.init()
    }
}

//MARK: methods for data read/write

extension DataManager {
    
    func push(messages:[Message]?, by:String) {
        if messages != nil {

            NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(messages! as NSArray), forKey: by)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func pop(user:String) -> [Message]? {
        
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(user) as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [Message]
        }
        return nil
    }
    
    func lgpop(user:String) -> [LGChatMessage] {
    
        var lgmessages = [LGChatMessage]()
        if let messages = pop(user) {
            for message in messages {
                lgmessages.append(LGChatMessage(content: message.text!, sentBy: LGChatMessage.SentBy(rawValue:message.by!)!, timeStamp: Double(message.time!)))
            }
        }
        return lgmessages
    }
}

//MARK: test data of DataManager

extension DataManager {
    
    private func test_json_file() -> String {
        return "test_messages.json"
    }
    
    private func test_data() -> NSData {
        
        if let file = NSBundle.mainBundle().pathForResource(test_json_file(), ofType: nil) {
            return NSData(contentsOfFile: file)!
        }
        return NSData()
    }
    
    func test_messages() -> [Message] {
        
        var messages = [Message]()
        
        do {
            
            let json = try NSJSONSerialization.JSONObjectWithData(test_data(), options: .AllowFragments)
            
            if let mess = json["messages"] as? [[String:AnyObject]] {
                for message in mess {
                    if let by = message["by"] as? String {
                        messages.append(Message(text: message["text"] as? String, by: by, time: message["time"] as? String))
                    }
                }
            }
        }
        catch {
            print("error serializing JSON: \(error)")
        }
        
        return messages
    }
    
    func test_random_message() -> Message? {
        
        let messages = test_messages()
        if messages.count > 0 {
            let rand = arc4random_uniform(UInt32(messages.count))
            return messages[Int(rand)]
        }
        return nil
    }
}
