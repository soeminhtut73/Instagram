//
//  Notification.swift
//  Instagram
//
//  Created by S M H  on 23/02/2025.
//

import UIKit
import Firebase

enum NotificationType: Int {
    case like // 0
    case follow // 1
    case comment // 2
    
    var notificationMessage: String {
        switch self {
            case .like:     return " liked your post."
            case .follow:   return " started following you."
            case .comment:  return " commented on your post."
        }
    }
}

struct Notification {
    let id              : String
    let uid             : String
    let timestamp       : Timestamp
    let type            : NotificationType
    var postImageUrl    : String?
    var postId          : String?
    
    init(dictionary : [String : Any]) {
        self.id                 = dictionary["id"] as? String ?? ""
        self.uid                = dictionary["uid"] as? String ?? ""
        self.timestamp          = dictionary["timestamp"] as? Timestamp ?? Timestamp()
        self.type               = NotificationType(rawValue: dictionary["type"] as? Int ?? 0) ?? .like
        self.postImageUrl       = dictionary["postImageUrl"] as? String ?? ""
        self.postId             = dictionary["postId"] as? String ?? ""
    }
}
