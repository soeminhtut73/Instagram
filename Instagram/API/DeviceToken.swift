//
//  DeviceToken.swift
//  Instagram
//
//  Created by S M H  on 02/04/2025.
//
import FirebaseAuth


struct DeviceToken {
    
    static func saveDeviceToken(currentUid: String, token: String) {
        
        let data : [String : String] = ["uid" : currentUid,
                                        "token" : token,]
        
        COLLECTION_DEVICE_TOKENS.whereField("uid", isEqualTo: currentUid).getDocuments { snapshot, error in
            
            if let error = error {
                print("Debug: Error fetching device token : \(error)")
            }
            
            if let document = snapshot?.documents.first {
                
                let docID = document.documentID
                COLLECTION_DEVICE_TOKENS.document(docID).setData(data, merge: true) { error in
                    if let error = error {
                        print("Debug: Failed to update device token: \(error.localizedDescription)")
                    } else {
                        print("Debug: Device token updated.")
                    }
                }
            } else {
                COLLECTION_DEVICE_TOKENS.addDocument(data: data) { error in
                    if let error = error {
                        print("Debug: Failed to add device token: \(error.localizedDescription)")
                    } else {
                        print("Debug: Device token added.")
                    }
                }
            }
        }
    }
}
