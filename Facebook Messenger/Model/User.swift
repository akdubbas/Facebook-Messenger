//
//  User.swift
//  Facebook Messenger
//
//  Created by Amith Dubbasi on 2/6/18.
//  Copyright © 2018 iDiscover. All rights reserved.
//

import UIKit


//User model contains id,Name,Email, URL for profile image
class User: NSObject {
    
    var id: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }

}
