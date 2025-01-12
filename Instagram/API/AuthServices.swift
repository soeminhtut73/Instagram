//
//  AuthenticationServices.swift
//  Instagram
//
//  Created by S M H  on 18/12/2024.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct AuthCredential {
    var email: String
    var password: String
    var username: String
    var fullName: String
    var profileImage: UIImage
}

struct AuthServices {
    
    static func logUserIn(email: String, password: String, completion: @escaping(AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUser(withCredential credential: AuthCredential, completion: @escaping(Error?) -> Void) {
        ImageUploader.uploadImage(image: credential.profileImage) { imageURL in
            
            Auth.auth().createUser(withEmail: credential.email, password: credential.password) { result, error in
                /// catch error to create user
                if let error = error {
                    print("Debug: Fail to create user: \(error.localizedDescription)")
                    return
                }
                
                guard let uid = result?.user.uid else { return }
                
                let data : [String : Any] = ["email" : credential.email,
                                             "username" : credential.username,
                                             "fullName" : credential.fullName,
                                             "uid" : uid,
                                             "profileImageUrl" : imageURL]
                
                COLLECTION_USERS.document(uid).setData(data, completion: completion)
            }
        }
    }
}
