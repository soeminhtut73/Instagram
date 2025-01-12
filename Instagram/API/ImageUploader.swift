//
//  ImageUploader.swift
//  Instagram
//
//  Created by S M H  on 18/12/2024.
//

import FirebaseStorage

let storage = Storage.storage()
let storageRef = storage.reference()

struct ImageUploader {
    static func uploadImage(image: UIImage, completion: @escaping(String) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let filename = UUID().uuidString
        
        let imageRef = storage.reference(withPath: "/profile_images/\(filename).jpg")
        
        let _ = imageRef.putData(imageData) { metadata, error in
            if let error = error {
                print("Debug: Fail to upload profile_images \(error.localizedDescription)")
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Debug: Fail to download profile_images \(error.localizedDescription)")
                }
                
                guard let imageURL = url?.absoluteString else { return }
                completion(imageURL)
            }
        }
        
        // Monitor progress (optional)
//        uploadTask.observe(.progress) { snapshot in
//            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
//            print("Progress: \(percentComplete)%")
//        }
    }
}
