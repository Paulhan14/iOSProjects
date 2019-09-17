//
//  BoardsModel.swift
//  Pentomino
//
//  Created by Jiaxing Han on 9/16/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation

//  Class for all type of boards
class BoardsModel {
    private let boardCount: Int
    //  Name of each board, or the image file name
    private let names: [String]
    
    init() {
        self.boardCount = 6
        var _names: [String] = []
        for i in 0..<self.boardCount {
            _names.append("Board\(i)")
        }
        self.names = _names
    }
    //  Get board name based on given index
    func getBoardNameOf(index: Int) -> String {
        return self.names[index]
    }
    
    func getBoardCount() -> Int {
        return self.boardCount
    }
}
