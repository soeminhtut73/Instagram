//
//  PostViewModel.swift
//  Instagram
//
//  Created by S M H  on 15/01/2025.
//

import UIKit
import Firebase

struct  PostViewModel {
    var post: Post
    
    var caption: String {
        return post.caption
    }
    
    var imageURL: URL? {
        return URL(string: post.imageURL)
    }
    
    var profileImageURL : URL? {
        return URL(string: post.profileImageURL)
    }
    
    var username : String {
        return post.username
    }
    
    var likeButtonTintColor: UIColor {
        return post.didLike ? .black : .white
    }
    
    var likeButtonImage: UIImage {
        let img = post.didLike ? "like_selected" : "like_unselected"
        return UIImage(named: img)!
    }
    
    var likeCount : Int {
        return post.likes
    }
    
    var likeLabel : String {
        if likeCount <= 1 {
            return "\(likeCount) like"
        } else {
            return "\(likeCount) likes"
        }
    }
    
    init(post: Post) {
        self.post = post
    }
}
