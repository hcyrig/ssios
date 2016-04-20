//
//  Message.swift
//  SMessenger
//
//  Created by Kostia Girych on 4/20/16.
//  Copyright © 2016 The Three Ways. All rights reserved.
//

import Foundation

//MARK: - Message class for serialization

class Message: NSObject, NSCoding {
    
    var text:String?
    var by:String?
    var time:String?
    
    func lgchatmessage(by:LGChatMessage.SentBy) -> LGChatMessage? {
        
        if let text = self.text {
            return LGChatMessage(content: text, sentBy: by)
        }
        return nil
    }
    
    func test_random_lgmessage() -> LGChatMessage? {
        return lgchatmessage(LGChatMessage.SentBy.Opponent)
    }
    
    init(text: String?, by:String?, time: String?) {
        self.text = text
        self.by = by
        self.time = time
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let text = aDecoder.decodeObjectForKey("text")
        let by = aDecoder.decodeObjectForKey("by")
        let time = aDecoder.decodeObjectForKey("time")
        self.init(text: text as? String, by: by as? String, time: time as? String)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(text, forKey: "text")
        aCoder.encodeObject(by, forKey: "by")
        aCoder.encodeObject(time, forKey: "time")
    }
}