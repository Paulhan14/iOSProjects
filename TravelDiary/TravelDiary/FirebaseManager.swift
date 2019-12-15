//
//  FirebaseManager.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/19/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    let userController = UserController.userController
    
    init() {}
    
    func saveUserDataToFirebase(_ payload: [String:String], _ uid: String) {
        // Upload data
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        // Create a new document for the user
        ref = db.collection("users").document(uid)
        ref!.setData(payload, completion: { (error) in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        })
    }
    
    func getUserDataFromFirebase(_ uid: String,completion: @escaping ([String:String]) -> Void) {
        var userData = [String:String]()
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let document = document, document.exists {
                    userData = document.data() as! [String : String]
                    completion(userData)
                }
            }
        }
    }
    
    func savePostToFirebase(_ post: Post) {
        guard post.owner != nil else { return }
        let uid = post.owner!.uid
        
        var payload = [String:Any]()
        payload["id"] = post.id
        payload["location"] = post.location
        payload["latitude"] = post.latitude
        payload["longitude"] = post.longitude
        payload["text"] = post.text
        payload["weather"] = post.weather
        payload["steps"] = post.steps
        let format = DateFormatter()
        format.dateFormat = "MM/dd/yyyy HH:mm"
        let postDateString = format.string(from: post.time!)
        payload["time"] = postDateString
        
        let db = Firestore.firestore()
        db.collection("postsOfUser").document(uid!).collection("posts").addDocument(data: payload) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                if let imageData = post.image, let user = Auth.auth().currentUser {
                    let uid = user.uid
                    let postId = post.id!
                    let storage = Storage.storage()
                    let storageRef = storage.reference()
                    let imageRef = storageRef.child("\(uid)/posts/\(postId).jpeg")
                    // Upload the file to the path
                    let uploadTask = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Upload image error: \(error.localizedDescription)")
                        }
                    }
                    
                    // Listen for state changes, errors, and completion of the upload.
                    uploadTask.observe(.resume) { snapshot in
                        // Upload resumed, also fires when the upload starts
                    }
                    
                    uploadTask.observe(.pause) { snapshot in
                        // Upload paused
                    }
                    
                    uploadTask.observe(.progress) { snapshot in
                        // Upload reported progress
                        let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                            / Double(snapshot.progress!.totalUnitCount)
                        print("Upload in progress: \(percentComplete)%")
                    }
                    
                    uploadTask.observe(.success) { snapshot in
                        // Upload completed successfully
                        print("Upload completed!")
                    }
                    
                    uploadTask.observe(.failure) { snapshot in
                        if let error = snapshot.error as NSError? {
                            switch (StorageErrorCode(rawValue: error.code)!) {
                            case .objectNotFound:
                                // File doesn't exist
                                print("Upload error: \(String(describing: error.localizedFailureReason))")
                                break
                            case .unauthorized:
                                // User doesn't have permission to access file
                                print("Upload error: \(String(describing: error.localizedFailureReason))")
                                break
                            case .cancelled:
                                // User canceled the upload
                                print("Upload error: \(String(describing: error.localizedFailureReason))")
                                break
                            case .unknown:
                                // Unknown error occurred, inspect the server response
                                print("Upload error: \(String(describing: error.localizedFailureReason))")
                                break
                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getUserPosts(_ uid: String, completion: @escaping ([[String:Any]]) -> Void) {
        var postData = [[String:Any]]()
        let db = Firestore.firestore()
        let docRef = db.collection("postsOfUser").document(uid).collection("posts")
        docRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    postData.append(document.data())
                }
                completion(postData)
            }
        }
    }
    
    func downloadImage(postId: String, completion: @escaping (Data) -> Void) {
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageRef = storageRef.child("\(uid)/posts/\(postId).jpeg")
            imageRef.getData(maxSize: 3 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Download error: \(error.localizedDescription)")
                } else {
                    completion(data!)
                }
            }
        } else {
            print("No user signed in")
        }
        
    }
    
    func uploadProfileImageOfUser(_ uid: String, _ imageData: Data) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("\(uid)/profile/profile.jpeg")
        // Upload the file to the path
        let uploadTask = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Upload profile image error: \(error.localizedDescription)")
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print("Upload in progress: \(percentComplete)%")
        }
        
        uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
            print("Upload completed!")
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    // File doesn't exist
                    print("Upload error: \(String(describing: error.localizedFailureReason))")
                    break
                case .unauthorized:
                    // User doesn't have permission to access file
                    print("Upload error: \(String(describing: error.localizedFailureReason))")
                    break
                case .cancelled:
                    // User canceled the upload
                    print("Upload error: \(String(describing: error.localizedFailureReason))")
                    break
                case .unknown:
                    // Unknown error occurred, inspect the server response
                    print("Upload error: \(String(describing: error.localizedFailureReason))")
                    break
                default:
                    break
                }
            }
        }
    }
    
    func downloadProfileImageOfUser(_ uid: String, completion: @escaping (Data) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("\(uid)/profile/profile.jpeg")
        imageRef.getData(maxSize: 3 * 1024 * 1024) { data, error in
            if let error = error {
                print("Download profile image error: \(error.localizedDescription)")
            } else {
                completion(data!)
            }
        }
    }
}
