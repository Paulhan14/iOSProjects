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
    
    var posts: [Post]
    var draft: Post?
    
    init() {
        // try to fetch a list of posts
        let context = DataManager.theManager.context
        let request = NSFetchRequest<Post>(entityName: "Post")
        do {
            let allPosts = try context.fetch(request)
            var _posts = [Post]()
            for aPost in allPosts {
                // If it is a draft
                if aPost.isDraft {
                    self.draft = aPost
                } else {
                    _posts.append(aPost)
                }
            }
            self.posts = _posts
        } catch {
            posts = [Post]()
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
        managedContext.insert(post)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save post. \(error)")
        }
        posts.append(post)
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
        post.isDraft = true
        managedContext.insert(post)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save post. \(error)")
        }
        self.draft = post
    }
    
    func deleteDraft() {
        // Make sure draft is not nil
        guard self.draft != nil else {return}
        // Delete draft from context
        let managedContext = DataManager.theManager.context
        let request = NSFetchRequest<Post>(entityName: "Post")
        do {
            let allPosts = try managedContext.fetch(request)
            for aPost in allPosts {
                // If it is a draft
                if aPost.isDraft {
                    managedContext.delete(aPost)
                }
            }
        } catch {
            print("Error deleting")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save post. \(error)")
        }
        // Make pointer nil
        self.draft = nil
        
    }
}
