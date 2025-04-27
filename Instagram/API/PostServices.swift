//
//  PostServices.swift
//  Instagram
//
//  Created by S M H  on 12/01/2025.
//

import UIKit
import Firebase
import FirebaseAuth
import YPImagePicker

struct PostServices {
    
    static func uploadPost(user: User, image: UIImage, caption: String, completion: @escaping(FirestoreCompletion)) {
        
        ImageUploader.uploadImage(image: image, image_path: "post_images") { imageURL in
            
            let postData: [String: Any] = ["ownerID"            : user.uid,
                                           "profileImageURL"    : user.profileImageUrl,
                                           "username"           : user.username,
                                           "caption"            : caption,
                                           "likes"              : 0,
                                           "imageURL"           : imageURL,
                                           "timestamp"          : Timestamp(date: Date())]
            
            COLLECTION_POSTS.addDocument(data: postData, completion: completion)
        }
    }
    
    static func uploadPostWithVideo(user: User, thumbnailImage: UIImage, video: YPMediaVideo, caption: String, completion: @escaping(FirestoreCompletion)) {
        
        ImageUploader.uploadImage(image: thumbnailImage, image_path: "post_images") { imageURL in
            ImageUploader.uploadVideo(video: video.url, video_path: "post_videos") { videoURL in
                let postData: [String: Any] = ["ownerID"            : user.uid,
                                               "profileImageURL"    : user.profileImageUrl,
                                               "username"           : user.username,
                                               "caption"            : caption,
                                               "likes"              : 0,
                                               "imageURL"           : imageURL,
                                               "videoURL"           : videoURL,
                                               "timestamp"          : Timestamp(date: Date())]
                
                COLLECTION_POSTS.addDocument(data: postData, completion: completion)
            }
        }
    }
    
    static func updatePost(forPost postId: String, newPostImageURL: String? = nil, newCaption: String? = nil, completion: @escaping(FirestoreCompletion)) {
        
        let updateData = ["caption" : newCaption,
                          "imageURL" : newPostImageURL].compactMapValues{ $0 }
        
        guard !updateData.isEmpty else {
            print("Debug: no update to performed.")
            completion(nil)
            return }
        
        print("Debug: updateData : \(updateData)")
        
        let postRef = COLLECTION_POSTS.document(postId)
        
        postRef.updateData(updateData) { error in
            if let error = error {
                print("Debug: Error updating user data : \(error.localizedDescription)")
                completion(error)
            }
            print("Debug: Successfully updated user profile.")
            completion(nil)
        }
        
        
    }
    
    // get posts for main feed view - limit - 20
    static func fetchPost(completion: @escaping([Post]) -> Void ) {
        COLLECTION_POSTS.order(by: "timestamp", descending: true).limit(to: 10).getDocuments { snapshot, error in
            
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            let posts = documents.map( { Post(postID: $0.documentID, dictionary: $0.data()) } )
            
            completion(posts)
        }
    }
    
    // FIXME: - Need to Clear Duplicate code
    // get posts for lastTimeSeen
    static func fetchPostWithLastTimeSeen(completion: @escaping([Post]) -> Void) {
        
        if let users = UserDefaultManager.shared.userFollowings { // fetch users by userDefaults following lists
            
            COLLECTION_POSTS
                .whereField("ownerID", in: users)
                .order(by: "timestamp", descending: true)
                .getDocuments { snapshot, error in
                    guard error == nil else { return }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    let posts = documents.map( { Post(postID: $0.documentID, dictionary: $0.data()) } )
                    
                    completion(posts)
                }
            
        } else {
            
            UserServices.fetchFollowingUsers { users in // For new users fetching posts
                
                if users.isEmpty {
                    self.fetchPost { posts in
                        completion(posts)
                    }
                    return
                }
                
                UserDefaultManager.shared.userFollowings = users  // Set following-users array in userDefaults
                
                COLLECTION_POSTS
                    .whereField("ownerID", in: users)
                    .order(by: "timestamp", descending: true)
                    .getDocuments { snapshot, error in
                        guard error == nil else { return }
                        
                        guard let documents = snapshot?.documents else { return }
                        
                        let posts = documents.map( { Post(postID: $0.documentID, dictionary: $0.data()) } )
                        
                        completion(posts)
                    }
            }
        }
    }
    
    // get single post
    static func fetchSinglePost(with postID: String, completion: @escaping(Post) -> Void) {
        COLLECTION_POSTS.document(postID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching single posts: \(error.localizedDescription)")
            }
            
            guard let document = snapshot?.data() else { return }
            
            let post = Post(postID: postID, dictionary: document)
            
            completion(post)
        }
    }
    
    // get post for related user
    static func fetchPostByUserID(_ userID: String, completion: @escaping([Post]) -> Void ) {
        
        COLLECTION_POSTS
            .whereField("ownerID", isEqualTo: userID)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
            
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            let posts = documents.map( { Post(postID: $0.documentID, dictionary: $0.data()) } )
            
            completion(posts)
        }
    }
    
    /// update like-count on post (plus)
    /// create userID in post-likes-collection on post
    /// create postID in user-likes-collection on user
    static func likePost(with post: Post, completion: @escaping FirestoreCompletion) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_POSTS.document(post.postID).updateData(["likes": post.likes + 1])
        
        COLLECTION_POSTS.document(post.postID).collection("post-likes").document(uid).setData([:]) { error in
            
            if let error = error {
                print("DEBUG : Error like a post: \(error.localizedDescription)")
            }
            
            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postID).setData([:], completion: completion)
        }
    }
    
    /// update like-count on post (reduce)
    /// delete userID on post-likes-collection on post
    /// delete postID on user-likes-collection on user
    static func unlikePost(with post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_POSTS.document(post.postID).updateData(["likes": post.likes - 1])
        
        COLLECTION_POSTS.document(post.postID).collection("post-likes").document(uid).delete() { error in
            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postID).delete(completion: completion)
        }
    }
    
    /// check like-counts on user with postID exit or not
    static func checkIfUserLikePost(with post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_USERS.document(uid).collection("user-likes").document(post.postID).getDocument { snapshot, _ in
            let exist = snapshot?.exists ?? false
            completion(exist)
        }
    }
    
}
