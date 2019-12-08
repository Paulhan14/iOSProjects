//
//  UserModel.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/11/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation
import CoreData

class UserController {
    static let userController = UserController()
    var loginUser: User?
    
    init() {
        
    }
    
    func createUser(_ first: String, _ last: String, _ email: String, _ uid: String) {
        let managedContext = DataManager.theManager.context
        let user = User(context: managedContext)
        user.setValue(first, forKeyPath: "firstName")
        user.setValue(last, forKey: "lastName")
        user.setValue(email, forKey: "email")
        user.setValue(uid, forKey: "uid")
        managedContext.insert(user)
        self.loginUser = user
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateUser(_ first: String, _ last: String, _ email: String, _ uid: String) throws {
        let managedContext = DataManager.theManager.context
        let user = getUser(by: uid)
        user!.firstName = first
        user!.lastName = last
        user!.email = email
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getUser(by uid: String) -> User? {
        var returnUser: User? = nil
        let managedContext = DataManager.theManager.context
        let request = NSFetchRequest<User>(entityName: "User")
        request.predicate = NSPredicate(format: "uid == %@", uid)
        
        do {
            let users = try managedContext.fetch(request)
            if users.count >= 1 {
                returnUser = users[0]
            }
        } catch {
            print("user fetch error")
        }
        return returnUser
    }
}
