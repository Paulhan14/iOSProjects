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
    //  Letter name
    let shape: String
    //  x value on pieces board
    var originalX: Double
    //  y value on pieces board
    var originalY: Double
    //  width at first
    var width: Double
    //  height at first
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
