//
//  UserServices.swift
//  Instagram
//
//  Created by S M H  on 25/12/2024.
//

import Firebase
import FirebaseAuth

typealias FirestoreCompletion = ((any Error)?) -> Void

struct UserServices {
    
    // get current login user
    static func getCurrentUser(completion: @escaping (User) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_USERS.document(userID).getDocument { snapshot, error in
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let result = snapshot?.data() else { return }
            let user = User(dictionary: result)
            completion(user)
        }
    }
    
    // get all of users collection
    static func getAllUsers(completion: @escaping ([User]) -> Void) {
        
        let userRef = COLLECTION_USERS.order(by: "username", descending: true).limit(to: 10)
        
        userRef.getDocuments { snapshot, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            var users = snapshot.documents.map( { User(dictionary: $0.data())} )
            
            guard let user = Auth.auth().currentUser?.uid else { return }
            
            users.removeAll(where: { $0.uid == user } )
            
            completion(users)
        }
    }
    
    // searchBy username dynamic limit for 10
    static func searchUsers(byUsername username: String, completion: @escaping ([User]) -> Void) {
        
        let lowercasedSearchText = username.lowercased()
        let endPrefix = lowercasedSearchText + "\u{f8ff}"
        
        COLLECTION_USERS
            .whereField("username", isGreaterThanOrEqualTo: lowercasedSearchText)
            .whereField("username", isLessThanOrEqualTo: endPrefix)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let users = documents.map( { User(dictionary: $0.data()) } )
                completion(users)
            }
    }
    
    // Follow-Users
    static func followUsers(uID: String, completion: @escaping(FirestoreCompletion)) {
        
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING_USERS.document(currentUID).collection("user-followings").document(uID).setData([:]) { error in
            COLLECTION_FOLLOWER_USERS.document(uID).collection("user-followers").document(currentUID).setData([:], completion: completion)
        }
    }
    
    
    // Unfollow-Users
    static func unfollowUsers(uID: String, completion: @escaping(FirestoreCompletion)) {
        
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING_USERS.document(currentUID).collection("user-follwings").document(uID).delete { error in
            
            if let error = error {
                print("Debug: Fail to delete user-followings # \(error)")
                return
            }
            
            COLLECTION_FOLLOWER_USERS.document(uID).collection("user-followers").document(currentUID).delete(completion: completion)
            
        }
    }
    
    // Check user-following status
    static func checkUserFollowingStatus(uID: String, completion: @escaping(Bool) -> Void) {
        
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING_USERS.document(currentUID).collection("user-followings").document(uID).getDocument { snapshot, error in
            
            if let error = error {
                print("Debug: Fail get user-followings data # \(error)")
                return
            }
            
            let isFollow = snapshot?.exists ?? false
            completion(isFollow)
        }
    }
    
    // Check Posts, Followers, Followings counts
    static func fetchUserStats(uID: String, completion: @escaping(UserStats) -> Void) {
        
        COLLECTION_FOLLOWING_USERS.document(uID).collection("user-followings").getDocuments { snapshot, _ in
            
            let followings = snapshot?.count ?? 0
            
            COLLECTION_FOLLOWER_USERS.document(uID).collection("user-followers").getDocuments { snapshot, _ in
                
                let followers = snapshot?.count ?? 0
                
                let userStats = UserStats(followers: followers, followings: followings)
                completion(userStats)
            }
        }
    }
}
