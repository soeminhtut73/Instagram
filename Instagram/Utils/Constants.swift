//
//  Constants.swift
//  Instagram
//
//  Created by S M H  on 25/12/2024.
//

import Firebase
import FirebaseFirestore
import FirebaseStorage

let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_FOLLOWING_USERS = Firestore.firestore().collection("user-following")
let COLLECTION_FOLLOWER_USERS = Firestore.firestore().collection("user-followers")
