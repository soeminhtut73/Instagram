//
//  CommentServices.swift
//  Instagram
//
//  Created by S M H  on 28/01/2025.
//

import UIKit
import Firebase

struct CommentServices {
    
    static func uploadComments(comment: String, postID: String, user: User, completion: @escaping FirestoreCompletion) {
        
        let data: [String: Any] = [
            "uid" : user.uid,
            "username" : user.username,
            "comment": comment,
            "timestamp": Timestamp(date: Date()),
            "profileImageURL": user.profileImageUrl
        ]
        
        COLLECTION_POSTS.document(postID).collection("comments").addDocument(data: data, completion: completion)
    }
    
    // fetchComment by snapshot listener
    // dynamic update UI by adding new comments
    static func fetchComments(with postID: String, completion: @escaping ([Comment]) -> Void) {
        var comments = [Comment]()
        
        let query = COLLECTION_POSTS.document(postID).collection("comments").order(by: "timestamp", descending: true).limit(to: 10)
        
        query.addSnapshotListener { snapshot, error in
            snapshot?.documentChanges.forEach { change in
                if change.type == .added {
                    let data = change.document.data()
                    
                    let comment = Comment(dictionary: data)
                    comments.append(comment)
                }
            }
            completion(comments)
        }
    }
    
    
    
    
}
