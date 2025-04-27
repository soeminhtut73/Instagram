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
    static func getUser(uid userID: String, completion: @escaping (User) -> Void) {
        
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
    
    // update user-data
    static func updateUserProfile(for user: User, username newUsername: String? = nil, profileImageURL newProfileImageURL: String? = nil, completion: @escaping FirestoreCompletion) {
        
        let updateData = ["username" : newUsername,
                          "profileImageUrl" : newProfileImageURL].compactMapValues { $0 }
        
        guard !updateData.isEmpty else {
            print("Debug: no update to performed.")
            completion(nil)
            return }
        
        print("Debug: updateData : \(updateData)")
        
        let userRef = COLLECTION_USERS.document(user.uid)
        
        userRef.updateData(updateData) { error in
            
            if let error = error {
                print("Debug: Error updating user data : \(error.localizedDescription)")
                completion(error)
            }
            print("Debug: Successfully updated user profile.")
            completion(nil)
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
            
            UserDefaultManager.shared.appendUserIdToFollowingUsersIds(uID)
            
            COLLECTION_FOLLOWER_USERS.document(uID).collection("user-followers").document(currentUID).setData([:], completion: completion)
        }
    }
    
    
    // Unfollow-Users
    static func unfollowUsers(uID: String, completion: @escaping(FirestoreCompletion)) {
        
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING_USERS.document(currentUID).collection("user-followings").document(uID).delete { _ in
            
            UserDefaultManager.shared.removeUserIdFromFollowingUsersIds(uID)
            
            COLLECTION_FOLLOWER_USERS.document(uID).collection("user-followers").document(currentUID).delete(completion: completion)
            
        }
    }
    
    // fetchFollowing-Users
    static func fetchFollowingUsers(completion: @escaping([String]) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING_USERS.document(currentUserID).collection("user-followings").getDocuments { snapshot, _ in
            
            guard let documents = snapshot?.documents else { return }
            
            let users = documents.map( { $0.documentID } )
            completion(users)
        }
    }
    
    static func fetchFollowingUsers(withUser uId: String, completion: @escaping([User]) -> Void) {
        
        COLLECTION_FOLLOWING_USERS.document(uId).collection("user-followings").getDocuments { snapshot, _ in
            
            guard let documents = snapshot?.documents else { return }
            
            let users = documents.map({ $0.documentID })
            
            COLLECTION_USERS.whereField(FieldPath.documentID(), in: users).getDocuments { snapshot, _ in
                
                guard let searchDocuments = snapshot?.documents else { return }
                
                let results = searchDocuments.map({ User(dictionary: $0.data()) })
                
                completion(results)
            }
        }
    }
    
    // fetchFollower-Users
    static func fetchFollowerUsers(completion: @escaping([String]) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWER_USERS.document(currentUserID).collection("user-followers").getDocuments { snapshot, _ in
            
            guard let documents = snapshot?.documents else { return }
            
            let users = documents.map( { $0.documentID })
            completion(users)
        }
    }
    
    static func fetchFollowerUsers(withUser uId: String, completion: @escaping([User]) -> Void){
        
        COLLECTION_FOLLOWER_USERS.document(uId).collection("user-followers").getDocuments { snapshot, _ in
            
            guard let documents = snapshot?.documents else { return }
            
            let users = documents.map({ $0.documentID })
            
            COLLECTION_USERS.whereField(FieldPath.documentID(), in: users).getDocuments { snapshot, _ in
                
                guard let searchDocuments = snapshot?.documents else { return }
                
                let results = searchDocuments.map({ User(dictionary: $0.data()) })
                
                completion(results)
            }
        }
        
    }
    
    // Check user-following status
    static func checkUserFollowingStatus(uID: String, completion: @escaping(Bool) -> Void) {
        
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING_USERS.document(currentUID).collection("user-followings").document(uID).getDocument { snapshot, _ in
            
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
                
                COLLECTION_POSTS.whereField("ownerID", isEqualTo: uID).getDocuments { snapshot, _ in
                    
                    let posts = snapshot?.count ?? 0
                    
                    let userStats = UserStats(followers: followers, followings: followings, posts: posts)
                    completion(userStats)
                }
            }
        }
    }
}
