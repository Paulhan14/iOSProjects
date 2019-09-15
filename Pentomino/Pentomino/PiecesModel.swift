//
//  PiecesModel.swift
//  Pentomino
//
//  Created by Jiaxing Han on 9/14/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation

class PiecesModel {
    private let piecesCount = 12
    private let piecesNames : [String]
    
    init() {
        var _piecesNames = [String]()
        let shapes = ["F", "I", "L", "N", "P", "T", "U", "V", "W", "X", "Y", "Z"]
        
        for i in 0..<piecesCount {
            _piecesNames.append("Piece\(shapes[i])")
        }
        
        piecesNames = _piecesNames
    }
    
    func getPiecesCount() -> Int {
        return piecesCount
    }
    
    func getPieceNameAt(index: Int) -> String {
        return piecesNames[index]
    }
}
