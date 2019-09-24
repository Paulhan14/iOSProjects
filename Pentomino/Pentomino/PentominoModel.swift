//
//  Model.swift
//  Pentominoes
//
//  Created by John Hannan on 8/28/18.
//  Copyright (c) 2018 John Hannan. All rights reserved.
//

import Foundation

// identifies placement of a single pentomino on a board
struct Position : Codable {
    var x : Int
    var y : Int
    var isFlipped : Bool
    var rotations : Int
}

// A solution is a dictionary mapping piece names ("T", "F", etc) to positions
// All solutions are read in and maintained in an array
typealias Solution = [String:Position]
typealias Solutions = [Solution]

class Model {

    let allSolutions : Solutions //[[String:[String:Int]]]
    //  Variable added by Jiaxing Han
    //  Keep track of which board is displayed in the main board view
    private var boardType: Int
    
    init () {
        let mainBundle = Bundle.main
        let solutionURL = mainBundle.url(forResource: "Solutions", withExtension: "plist")
        
        do {
            let data = try Data(contentsOf: solutionURL!)
            let decoder = PropertyListDecoder()
            allSolutions = try decoder.decode(Solutions.self, from: data)
        } catch {
            print(error)
            allSolutions = []
        }
        //  Initialize board type to 0
        self.boardType = 0
    }
    //  Set current board type
    func setBoardType(type: Int) {
        self.boardType = type
    }
    
    func getBoardType() -> Int {
        return boardType
    }
    //  Find position of a piece on the CURRENT board type
    func findSolutionForPiece(name: String) -> Position{
        let solution = allSolutions[self.boardType-1]
        return solution[name]!
    }

}
