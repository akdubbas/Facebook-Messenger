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
    
    
    func chatPartnerId() -> String?
    {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }

}
