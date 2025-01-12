//
//  ProfileHeaderViewModel.swift
//  Instagram
//
//  Created by S M H  on 26/12/2024.
//

import UIKit

struct ProfileHeaderViewModel {
    var user: User
    
    var fullname: String {
        return user.fullName
    }
    
    var profileImageURL: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var username: String {
        return user.username
    }
    
    var followButtonTitle: String {
        if user.isCurrentUser {
            return "Edit Profile"
        } else {
            return user.isFollowed ? "Following" : "Follow"
        }
    }
    
    var folowButtonBackgroundColor: UIColor {
        return user.isCurrentUser ? .white : .systemBlue
    }
    
    var followButtonTextColor: UIColor {
        return user.isCurrentUser ? .black : .white
    }
    
    var isAuthUser: Bool {
        return user.isCurrentUser ? true : false
    }
    
    var numberOfFollwers: NSAttributedString {
        return attributeStatText(value: user.stats.followers, label: "Followers")
    }
    
    var numberOfFollwings: NSAttributedString {
        return attributeStatText(value: user.stats.followings, label: "Followers")
    }
    
    var numberOfPosts: NSAttributedString {
        return attributeStatText(value: 0, label: "Followers")
    }
    
    init(user: User) {
        self.user = user
    }
    
    func attributeStatText(value: Int, label: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: " \(value)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: label, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
}
