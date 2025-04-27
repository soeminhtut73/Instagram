//
//  Post.swift
//  Instagram
//
//  Created by S M H  on 14/01/2025.
//

import UIKit
import Firebase

struct Post {
    let ownerID         : String
    let postID          : String
    var caption         : String
    var likes           : Int
    var imageURL        : String
    let timestamp       : Timestamp
    let username        : String
    let profileImageURL : String
    let videoURL        : String?
    
    var didLike : Bool = false
    
    init(postID: String, dictionary: [String : Any]) {
        self.postID             = postID
        self.ownerID            = dictionary["ownerID"] as? String ?? ""
        self.caption            = dictionary["caption"] as? String ?? ""
        self.likes              = dictionary["likes"] as? Int ?? 0
        self.imageURL           = dictionary["imageURL"] as? String ?? ""
        self.timestamp          = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.username           = dictionary["username"] as? String ?? ""
        self.profileImageURL    = dictionary["profileImageURL"] as? String ?? ""
        self.videoURL           = dictionary["videoURL"] as? String ?? nil
    }
}
