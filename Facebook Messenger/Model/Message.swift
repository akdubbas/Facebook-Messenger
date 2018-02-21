//
//  Message.swift
//  Facebook Messenger
//
//  Created by Amith Dubbasi on 2/13/18.
//  Copyright © 2018 iDiscover. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId : String?
    var text : String?
    var timeStamp : NSNumber?
    var toId : String?
    var imageUrl:String?
    var imageHeight: NSNumber?
    var imageWidth : NSNumber?
    
    
    init(dictionary: [String: Any]) {
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.timeStamp = dictionary["timestamp"] as? NSNumber
        self.imageUrl = dictionary["imageUrl"] as? String
        
        
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
    }
    
    
    func chatPartnerId() -> String?
    {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }

}
