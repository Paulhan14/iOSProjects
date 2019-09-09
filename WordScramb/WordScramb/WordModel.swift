//
//  WordModel.swift
//  Word Challenge
//
//  Created by John Hannan on 6/17/19.
//  Copyright © 2019 John Hannan. All rights reserved.
//

import Foundation

class WordModel {
    
    private var words : [Int : [String]]  //maps word lengths to arrays of words
    private var currentWordSize = 4
    
    init() {
        let wordSizes = [4,5,6]   // 3 lengths of words supported
        var _words : [Int : [String]] = [:]
        
        for i in wordSizes {
            let fileName = "Words" + String(i)
            
            if let wordsFilePath = Bundle.main.path(forResource: fileName, ofType: nil) {
                do {
                    let wordsString = try String(contentsOfFile: wordsFilePath)
                    _words[i] = wordsString.components(separatedBy: .newlines)
                } catch { // contentsOfFile throws an error
                    print("Error: \(error)")
                    _words[i] = []
                }
            } else {
                print("Error: Missing \(fileName)")
                _words[i] = []
            }
        }
        words = _words

    }
    
    func setCurrentWordSize(newSize:Int) {
        currentWordSize = newSize
    }

    func isDefined(_ term:String) -> Bool {
        let theWords = words[currentWordSize]!
        let result = theWords.contains(term)
        return result
    }
    
    var randomWord : String {
        get  {
            let theWords = words[currentWordSize]!
            let bound = theWords.count
            let index = Int(arc4random_uniform(UInt32(bound)))
            return theWords[index]
        }
    }
    
    func correctResponse() -> String {
        let response = ["Congrats!👏", "Nice!👍", "Awesome✌️"]
        return response.randomElement()!
    }
    
    func wrongResponse() -> String {
        let response = ["Not right😕", "👋Not it", "Try next👇"]
        return response.randomElement()!
    }
    
}
