//
//  NotificationServices.swift
//  Instagram
//
//  Created by S M H  on 23/02/2025.
//

import UIKit
import Firebase

struct NotificationServices {
    
    
    static func uploadNotification(toUser user: User? = nil, toUid userID: String? = nil, type: NotificationType, post: Post? = nil) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        guard let uid = user?.uid ?? userID else { return }
        
        // FIXME: - Need to add skip to save notification if currentUid == userID
        
        let documentRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
        
        var dictionary: [String : Any] = ["id"          : documentRef.documentID,
                                          "uid"         : currentUid,
                                          "timestamp"   : Timestamp(date: Date()),
                                          "type"        : type.rawValue]
        
        if let post = post {
            dictionary["postImageUrl"]  = post.imageURL
            dictionary["postId"]        = post.postID
        }
        
        documentRef.setData(dictionary)
    }
    
    static func fetchUserNotification(completion: @escaping([NotificationViewModel]) -> Void) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_NOTIFICATIONS.document(currentUid).collection("user-notifications").order(by: "timestamp", descending: true).addSnapshotListener { snapshot, error in
            
            if let error = error {
                print("Error fetching user notifications: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            let group = DispatchGroup()
            
            var viewModels : [NotificationViewModel] = []
            
            for document in documents {
                
                group.enter()
                
                let notification = Notification(dictionary: document.data())
                
                UserServices.getUser(uid: notification.uid) { user in
                    
                    if notification.type == .follow {
                        UserServices.checkUserFollowingStatus(uID: notification.uid) { stats in
                            let isFollow = stats
                            let viewModel = NotificationViewModel(notification: notification, user: user, isFollow: isFollow)
                            
                            print("Debug: notiType : \(notification.type)")
                            print("Debug: userName : \(user.username)")
                            print("Debug: isFollow : \(isFollow)")
                            
                            viewModels.append(viewModel)
                            
                            group.leave()
                        }
                    } else {
                        let isFollow = false
                        let viewModel = NotificationViewModel(notification: notification, user: user, isFollow: isFollow)
                        
                        print("Debug: notiType : \(notification.type)")
                        print("Debug: userName : \(user.username)")
                        print("Debug: isFollow : \(isFollow)")
                        
                        viewModels.append(viewModel)
                        
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                completion(viewModels)  // Return the final result
            }
        }
    }
    
    static func fetchNoti(completion: @escaping([NotificationViewModel]) -> Void) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_NOTIFICATIONS.document(currentUid).collection("user-notifications").order(by: "timestamp", descending: true).addSnapshotListener { snapshot, error in
            
            if let error = error {
                print("Error fetching user notifications: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            let group = DispatchGroup()
            
            var viewModels : [NotificationViewModel] = []
            
            for document in documents {
                
                group.enter()
                
                let notification = Notification(dictionary: document.data())
                
                UserServices.getUser(uid: notification.uid) { user in
                    
                    let viewModel = NotificationViewModel(notification: notification, user: user)
                    
                    viewModels.append(viewModel)
                    
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(viewModels)  // Return the final result
            }
        }
    }
}
