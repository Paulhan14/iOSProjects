//
//  IntroModel.swift
//  StatePark
//
//  Created by Jiaxing Han on 10/13/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation

class IntroModel {
    let pageNum: Int
    let descriptions: [String]
    let imageNames: [String]
    
    init() {
        self.pageNum = 3
        self.descriptions = ["Tap the section to collapse the images", "Tap a cell to display detail of the selected image", "Supports full-screen image view with captions"]
        self.imageNames = ["collapse", "tap", "fullscreen"]
    }
    
}
