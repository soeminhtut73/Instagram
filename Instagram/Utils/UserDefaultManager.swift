//
//  UserDefaultManager.swift
//  Instagram
//
//  Created by S M H  on 15/03/2025.
//

import UIKit

enum UserDefaultKey {
    static let lastFetchPostTimestamp = "lastFetchPostTimestamp"
    static let followingUsersIds = "followingUsersIds"
}

class UserDefaultManager {
    
    static let shared = UserDefaultManager()
    private let userDefaults = UserDefaults.standard
    
    var userFollowings: [String]? {
        
        get {
            return userDefaults.array(forKey: UserDefaultKey.followingUsersIds) as? [String]
        }
        
        set {
            userDefaults.set(newValue, forKey: UserDefaultKey.followingUsersIds)
        }
    }
    
    func appendUserIdToFollowingUsersIds(_ userId: String) {
        
        var users = userDefaults.array(forKey: UserDefaultKey.followingUsersIds) as? [String] ?? []
        
        users.append(userId)
        
        userDefaults.set(users, forKey: UserDefaultKey.followingUsersIds)
    }
    
    func removeUserIdFromFollowingUsersIds(_ userId: String) {
        
        var users = userDefaults.array(forKey: UserDefaultKey.followingUsersIds) as? [String] ?? []
        
        if let index = users.firstIndex(of: userId) {
            users.remove(at: index)
        }
        
        userDefaults.set(users, forKey: UserDefaultKey.followingUsersIds)
    }
    
    func clearUserData() {
        userDefaults.removeObject(forKey: UserDefaultKey.followingUsersIds)
    }
}
