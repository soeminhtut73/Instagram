//
//  NotificationViewModel.swift
//  Instagram
//
//  Created by S M H  on 28/02/2025.
//

import UIKit

struct NotificationViewModel {
    
    public var notification : Notification
    
    public var user : User
    
    public var isFollow : Bool
    
    init(notification : Notification, user : User, isFollow : Bool = false) {
        self.notification = notification
        self.user = user
        self.isFollow = isFollow
    }
    
    var timestampString : String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter.string(from: notification.timestamp.dateValue(), to: Date())!
    }
    
    var postImageUrl : URL? {
        return URL(string: notification.postImageUrl ?? "")
    }
    
    var profileImageUrl : URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var username : String {
        return user.username
    }
    
    var labelText : String {
        return notification.type.notificationMessage
    }
    
    var shouldHidePostImageButton : Bool {
        return notification.type == .follow // true
    }
    
    var followButtonText : String {
        return isFollow ? "Following" : "Follow"
    }
    
    var followButtonBackgroundColor : UIColor {
        return isFollow ? .white : .systemBlue
    }
    
    var followButtonTextColor : UIColor {
        return isFollow ? .black : .white
    }
    
}
