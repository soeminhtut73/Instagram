//
//  UserDefaultManager.swift
//  Instagram
//
//  Created by S M H  on 15/03/2025.
//

import UIKit

enum UserDefaultKey {
//    static let lastFetchPostTimestamp = "lastFetchPostTimestamp"
    static let followingUsersIds = "followingUsersIds"

    static let deviceToken = "deviceToken"
}


class UserDefaultManager {  // FollowingUsersDefaults
    
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

extension UserDefaultManager { // Save or Retrieve deviceToken
    ///end point https://instagram-pushnotification-711825808880.us-central1.run.app
    
    var deviceToken: String? {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultKey.deviceToken)
        }
        
        set {
            userDefaults.set(newValue, forKey: UserDefaultKey.deviceToken)
        }
    }
    
    func clearDeviceToken() {
        userDefaults.removeObject(forKey: UserDefaultKey.deviceToken)
    }
}

