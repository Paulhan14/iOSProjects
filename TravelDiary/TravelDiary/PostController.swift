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

struct postsOfUser {
    var uid: String
    var posts: [Post]
}

struct postParameters {
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
    
    var posts: [Post]
    var draft: Draft?
    
    init() {
        // try to fetch a list of posts
        let context = DataManager.theManager.context
        let request = NSFetchRequest<Post>(entityName: "Post")
        do {
            let allPosts = try context.fetch(request)
            var _posts:[Post] = []
            for post in allPosts {
                if post.owner?.uid == UserController.userController.loginUser?.uid {
                    _posts.append(post)
                }
            }
            self.posts = _posts
        } catch {
            posts = [Post]()
        }
        
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
        managedContext.insert(post)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save post. \(error)")
        }
        posts.append(post)
        // Upload post to firebase
        firebaseManager.savePostToFirebase(post)
    }
    
    func deletePost(at index: Int) {
        let managedContext = DataManager.theManager.context
        let post = self.posts.remove(at: index)
        managedContext.delete(post)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete post. \(error)")
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
        managedContext.insert(draft)
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
            for postData in postGot {
                let post = Post(context: managedContext)
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
            
            // Delete draft from context
            let request = NSFetchRequest<Post>(entityName: "Post")
            do {
                let allPosts = try managedContext.fetch(request)
                for aPost in allPosts {
                    managedContext.delete(aPost)
                }
            } catch {
                print("Error deleting")
            }
            
            for aPost in self.posts{
                managedContext.insert(aPost)
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save draft. \(error)")
            }
        }
    }
}

