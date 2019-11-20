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
    
    func getUserDataFromFirebase(_ uid: String) -> [String:String] {
        var data = [String:String]()
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                data = document.data() as! [String:String]
            } else {
                print("Document does not exist")
            }
        }
        return data
    }

}
