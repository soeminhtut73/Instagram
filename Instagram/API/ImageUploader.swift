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
    static func uploadImage(image: UIImage, oldImageURL: String? = nil, image_path: String, completion: @escaping(String) -> Void) {
        
        if let oldURL = oldImageURL {
            
            let ref = Storage.storage().reference(forURL: oldURL)
            
            ref.delete { error in
                if let error = error {
                    print("Debug: Fail to delete old image \(error.localizedDescription)")
                }
                print("Debug: image deleted.")
            }
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let filename = UUID().uuidString
        
        let imageRef = storage.reference(withPath: "/\(image_path)/\(filename).jpg")
        
        let _ = imageRef.putData(imageData) { metadata, error in
            
            if let error = error {
                print("Debug: Fail to upload profile_images \(error.localizedDescription)")
                return
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
    
    static func uploadVideo(video: URL, video_path: String, completion: @escaping(String) -> Void) {
        
        let filename = UUID().uuidString + ".mp4"
        
        let videoRef = storage.reference(withPath: "/\(video_path)/\(filename)")
        
        videoRef.putFile(from: video, metadata: nil) { metadata, error in
            if let error = error {
                print("Debug: Upload video error: \(error)")
                return
            }
            
            videoRef.downloadURL { url, error in
                if let error = error {
                    print("Debug: Video download URL error: \(error)")
                    return
                }
                
                guard let url = url else { return }
                completion(url.absoluteString)
            }
        }
    }
}
