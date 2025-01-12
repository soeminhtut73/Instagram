//
//  User.swift
//  Instagram
//
//  Created by S M H  on 26/12/2024.
//

import UIKit
import FirebaseAuth

struct User {
    var email: String
    var fullName: String
    var username: String
    var profileImageUrl: String
    var uid: String
    
    var isFollowed: Bool = false
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }
    
    var stats: UserStats!
    
    init(dictionary: [String: Any]) {
        self.email = dictionary["email"] as? String ?? ""
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        
        self.stats = UserStats(followers: 0, followings: 0)
    }
}

struct UserStats {
    let followers: Int
    let followings: Int
//    let posts: Int
}
