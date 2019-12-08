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
    
//    func getUserDataFromFirebase(_ uid: String, _ email: String) {
//        var data = [String:String]()
//        let db = Firestore.firestore()
//        let docRef = db.collection("users").document(uid)
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                data = document.data() as! [String:String]
//                if let first = data["first"], let last = data["last"] {
//                    let loginUser = self.userController.getUser(by: uid)
//                    if loginUser == nil {
//                        self.userController.createUser(first, last, email, uid)
//                    } else {
//                        self.userController.loginUser = loginUser
//                    }
//                }
//            } else {
//                print("Document does not exist")
//            }
//        }
//    }
    
    func savePostToFirebase(_ post: Post) {
        guard post.owner != nil else { return }
        let uid = post.owner!.uid
        
        var payload = [String:Any]()
        payload["location"] = post.location
        payload["latitude"] = post.latitude
        payload["longitude"] = post.longitude
        payload["text"] = post.text
        // Too large to upload a image here
//        payload["image"] = post.image
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
}
