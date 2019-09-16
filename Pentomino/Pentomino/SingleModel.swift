//
//  SingleModel.swift
//  Pentomino
//
//  Created by Jiaxing Han on 9/16/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation

//  Class for a single pentomino piece
class PentominoPiece {
    let shape: String
    var originalX: Double
    var originalY: Double
    var width: Double
    var height: Double
    
    init(shape:String) {
        self.shape = shape
        originalX = 0.0
        originalY = 0.0
        width = 0.0
        height = 0.0
    }
    
    func generateName() -> String {
        return "Piece\(self.shape)"
    }
    
    func setOriginalX(x: Double) {
        self.originalX = x
    }
    
    func setOriginalY(y: Double) {
        self.originalY = y
    }
    
    func setWidth(width: Double) {
        self.width = width
    }
    
    func setHeight(height: Double) {
        self.height = height
    }
}
