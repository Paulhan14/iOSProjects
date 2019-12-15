//
//  PostModel.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/11/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct postParameters {
    var id: String
    var time: Date
    var type: Int16
    var mood: Int16
    var location: String
    var longitude: Double
    var latitude: Double
    var weather: String
    var text: String
    var steps: String
    var image: Data
    var isPublic: Bool
    var isDraft: Bool
    
    init() {
        id = String()
        time = Date()
        type = Int16()
        mood = Int16()
        location = String()
        longitude = Double()
        latitude = Double()
        weather = String()
        text = String()
        image = Data()
        steps = String()
        isPublic = false
        isDraft = false
    }
}

class PostController {
    static let postController = PostController()
    let firebaseManager = FirebaseManager.shared
    let userController = UserController.userController
    
    var posts = [Post]()
    var draft: Draft?
    
    init() {
        let context = DataManager.theManager.context
        
        let draftRequest = NSFetchRequest<Draft>(entityName: "Draft")
        do {
            let drafts = try context.fetch(draftRequest)
            if drafts.count >= 1 {
                self.draft = drafts[0]
            }
        } catch {
            self.draft = Draft()
        }
    }
    
    func createPost(_ configure: postParameters) {
        let managedContext = DataManager.theManager.context
        let post = Post(context: managedContext)
        let format = DateFormatter()
        format.dateFormat = "MMddyyyyhhss"
        let postDateString = format.string(from: configure.time)
        post.id = postDateString
        post.time = configure.time
        post.type = configure.type
        post.mood = configure.mood
        post.location = configure.location
        post.longitude = configure.longitude
        post.latitude = configure.latitude
        post.weather = configure.weather
        post.text = configure.text
        post.image = configure.image
        post.steps = configure.steps
        post.isPublic = configure.isPublic
        post.isDraft = false
        post.owner = UserController.userController.loginUser
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save post. \(error)")
        }
        posts.append(post)
        // Upload post to firebase
        firebaseManager.savePostToFirebase(post)
    }
    
    func deleteAllPosts() {
        let managedContext = DataManager.theManager.context
        // Delete the existing posts from context
        let request = NSFetchRequest<Post>(entityName: "Post")
        do {
            let allPosts = try managedContext.fetch(request)
            for aPost in allPosts {
                managedContext.delete(aPost)
            }
        } catch {
            print("Error deleting")
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not update post. \(error)")
        }
    }
    
    func updatePost(_ configure: postParameters, _ post: Post) {
        let managedContext = DataManager.theManager.context
        post.time = configure.time
        post.type = configure.type
        post.mood = configure.mood
        post.location = configure.location
        post.longitude = configure.longitude
        post.latitude = configure.latitude
        post.weather = configure.weather
        post.text = configure.text
        post.image = configure.image
        post.steps = configure.steps
        post.isPublic = configure.isPublic
        post.isDraft = false
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not update post. \(error)")
        }
    }
    
    // MARK: for draft
    func createDraft(_ configure: postParameters) {
        let managedContext = DataManager.theManager.context
        let draft = Draft(context: managedContext)
        draft.time = configure.time
        draft.time = configure.time
        draft.type = configure.type
        draft.mood = configure.mood
        draft.location = configure.location
        draft.longitude = configure.longitude
        draft.latitude = configure.latitude
        draft.weather = configure.weather
        draft.text = configure.text
        draft.image = configure.image
        draft.steps = configure.steps
        draft.isPublic = configure.isPublic
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save draft. \(error)")
        }
        self.draft = draft
    }
    
    func deleteDraft() {
        // Make sure draft is not nil
        guard self.draft != nil else {return}
        // Delete draft from context
        let managedContext = DataManager.theManager.context
        let request = NSFetchRequest<Draft>(entityName: "Draft")
        do {
            let allDrafts = try managedContext.fetch(request)
            for aDraft in allDrafts {
                managedContext.delete(aDraft)
            }
        } catch {
            print("Error deleting")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save draft. \(error)")
        }
        // Make pointer nil
        self.draft = nil
    }
    
    // Get posts
    func getPostForCurrentUser(_ uid: String) {
        var _posts = [Post]()
        firebaseManager.getUserPosts(uid) { postGot in
            let managedContext = DataManager.theManager.context
            // Delete the existing posts from context
            let request = NSFetchRequest<Post>(entityName: "Post")
            do {
                let allPosts = try managedContext.fetch(request)
                for aPost in allPosts {
                    managedContext.delete(aPost)
                }
            } catch {
                print("Error deleting")
            }
            // Insert new posts into context
            for postData in postGot {
                let post = Post(context: managedContext)
                post.id = postData["id"] as? String
                post.text = postData["text"] as? String
                post.location = postData["location"] as? String
                post.latitude = postData["latitude"] as! Double
                post.longitude = postData["longitude"] as! Double
                post.weather = postData["weather"] as? String
                post.steps = postData["steps"] as? String
                let format = DateFormatter()
                format.dateFormat = "MM/dd/yyyy HH:mm"
                let postDateString: String? = postData["time"] as? String
                post.time = format.date(from: postDateString!)
                post.owner = self.userController.loginUser
                _posts.append(post)
            }
            self.posts = _posts
            
            for post in self.posts {
                self.firebaseManager.downloadImage(postId: post.id!) { (data) in
                    post.image = data
                }
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save draft. \(error)")
            }
        }
        
        
        
    }
}

