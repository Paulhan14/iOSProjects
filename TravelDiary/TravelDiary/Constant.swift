//
//  Constant.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/10/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation

struct Constant {
    struct StoryBoardID {
        static let postsView = "MyPosts"
        static let appView = "MainApp"
        static let composeView = "WritePostView"
        static let loginView = "LoginView"
        static let locationSearchView = "LocationSearchView"
        static let locationSearchTable = "LocationSearchTable"
        static let postView = "PostViewController"
    }
    
    struct Segues {
        static let signup = "SignupSegue"
        static let login = "LoginSegue"
    }
    
    struct CellIdentifier {
        static let locationCell = "LocationCell"
        static let myPostCell = "MyPostCell"
        static let dateCell = "DateCell"
    }
}

extension Notification.Name {
    static let userCreated = Notification.Name("UserCreatedNotification")
}
