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
    var weather: String
    var text: String
    var steps: String
    var isPublic: Bool
}

class PostController {
    static let postController = PostController()
    
    var posts: [Post]
    
    init() {
        // try to fetch a list of posts
        let context = DataManager.theManager.context
        let request = NSFetchRequest<Post>(entityName: "Post")
        do {
            posts = try context.fetch(request)
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
        post.weather = configure.weather
        post.text = configure.text
        post.steps = configure.steps
        post.isPublic = configure.isPublic
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
        post.weather = configure.weather
        post.text = configure.text
        post.steps = configure.steps
        post.isPublic = configure.isPublic
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not update post. \(error)")
        }
    }
}
