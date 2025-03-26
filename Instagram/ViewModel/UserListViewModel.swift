//
//  UserListViewModel.swift
//  Instagram
//
//  Created by S M H  on 26/03/2025.
//

import UIKit

struct UserListViewModel {
    
    public var user: User
    
    public var type: buttonType
    
    init(user: User, type: buttonType) {
        self.user = user
        self.type = type
    }
    
    var profileImageURL: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var username: String {
        return user.username
    }
    
    var buttonTitle: String {
        if type == .followings {
            return "Followings"
        } else {
            switch user.isFollowed {
            case true: return "Followings"
            case false: return "Follow"
            }
        }
    }
    
    var buttonBackgroundColor: UIColor {
        if type == .followings {
            return .white
        } else {
            switch user.isFollowed {
            case true: return .white
            case false: return .systemBlue
            }
        }
    }
    
    var buttonTextColor: UIColor {
        if type == .followings {
            return .black
        } else {
            switch user.isFollowed {
            case true: return .black
            case false: return .white
            }
        }
    }
}
