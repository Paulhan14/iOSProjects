//
//  PiecesModel.swift
//  Pentomino
//
//  Created by Jiaxing Han on 9/14/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation

//  Manages all the pentomino pieces
class PiecesModel {
    //  Array contains all the pentominos
    let pieces : [PentominoPiece]
    
    init() {
        var _pieces = [PentominoPiece]()
        let shapes = ["F", "I", "L", "N", "P", "T", "U", "V", "W", "X", "Y", "Z"]
        //  Assign names to each pieces
        for i in 0..<shapes.count {
            let aPiece = PentominoPiece(shape: shapes[i])
            _pieces.append(aPiece)
        }
        pieces = _pieces
    }
    //  Return total pieces count
    func getPiecesCount() -> Int {
        return pieces.count
    }
    
    func getAPiece(index: Int) -> PentominoPiece {
        return pieces[index]
    }
}
