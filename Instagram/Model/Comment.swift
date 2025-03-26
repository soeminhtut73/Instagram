//
//  Comment.swift
//  Instagram
//
//  Created by S M H  on 28/01/2025.
//

import UIKit
import Firebase

struct Comment {
    let uid             : String
    let username        : String
    let comment         : String
    let profileImageURL : String
    let timestamp       : Timestamp
    
    init(dictionary : [String : Any]) {
        self.uid                = dictionary["uid"] as? String ?? ""
        self.username           = dictionary["username"] as? String ?? ""
        self.comment            = dictionary["comment"] as? String ?? ""
        self.profileImageURL    = dictionary["profileImageURL"] as? String ?? ""
        self.timestamp          = dictionary["timestamp"] as? Timestamp ?? Timestamp()
    }
}
