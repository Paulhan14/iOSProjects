//
//  ViewController.swift
//  WordScramb
//
//  Created by Jiaxing Han on 9/2/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var roundCount : Int = 0            //  Count how many games have been played
    var winCount : Int = 0              //  Count how many times did user win
    var currentWordLength : Int = 4     //  Current word length
    var userGuess : String = ""         //  Stores user's guess in a game
    var currentWord : String = ""       //  Correct answer(generated by WordModel)
    var currentWordInChar : [Character] = [] // The word in an array of Characters
    var lastSelectedLetters : [Int] = [] // Stores the index of segment selected by user
    
    //  WordModel instance
    let wordModel = WordModel()
    
    //  MARK: Properties
    @IBOutlet weak var userAnswerLabel: UILabel!
    
    @IBOutlet weak var gameOutcomeLabel: UILabel!
    
    @IBOutlet weak var letterPickSegmentCtrl: UISegmentedControl!
    
    @IBOutlet weak var wordLengthPickSegmentCtrl: UISegmentedControl!
    
    @IBOutlet weak var undoButton: UIButton!
    
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var newWordButton: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Initialize Segmentation Control titles
        for i in 0...2 {
            wordLengthPickSegmentCtrl.setTitle(String(i+4), forSegmentAt: i)
        }
        for i in 0...3 {
            letterPickSegmentCtrl.setTitle("", forSegmentAt: i)
        }
        letterPickSegmentCtrl.selectedSegmentIndex = -1
        
        //Set Undo and Check button disabled
        undoButton.isEnabled = false
        undoButton.setTitleColor(UIColor.gray, for: .disabled)
        checkButton.isEnabled = false
        checkButton.setTitleColor(UIColor.gray, for: .disabled)
        newWordButton.setTitleColor(UIColor.gray, for: .disabled)
    }

    
    //  MARK: Actions
    @IBAction func undoPressed(_ sender: Any) {
        if lastSelectedLetters.isEmpty == false {
            letterPickSegmentCtrl.setEnabled(true, forSegmentAt: lastSelectedLetters.removeLast())
            let tempText : String = (String)(userGuess.dropLast())
            userGuess = tempText
            userAnswerLabel.text = userGuess
            if lastSelectedLetters.isEmpty {
                undoButton.isEnabled = false
            }
            if lastSelectedLetters.count < currentWordLength {
                checkButton.isEnabled = false
            }
            
        }
    }
    
    //  When user press Check button
    @IBAction func checkPressed(_ sender: Any) {
        //Check user's guess
        if userGuess == currentWord {
            gameOutcomeLabel.text = wordModel.correctResponse()
            winCount += 1
        } else {
            gameOutcomeLabel.text = wordModel.wrongResponse()
        }
        userAnswerLabel.text = currentWord
        //Reset the variable used as a game has ended
        userGuess = ""
        currentWordInChar = []
        lastSelectedLetters = []
        newWordButton.isEnabled = true
        wordLengthPickSegmentCtrl.isEnabled = true
        undoButton.isEnabled = false
        checkButton.isEnabled = false
        scoreLabel.text = "\(winCount) out of \(roundCount) Correct"
    }
    
    //  When user press the New Word button, marks as the start of a game
    @IBAction func newWordPressed(_ sender: Any) {
        //Initialize for a new game
        userAnswerLabel.text = ""
        gameOutcomeLabel.text = ""
        for i in 0...currentWordLength-1 { //Enable all the letter-pick segments
            letterPickSegmentCtrl.setEnabled(true, forSegmentAt: i)
        }
        wordLengthPickSegmentCtrl.isEnabled = false //Disable the word length set segment control
        
        //Get a new word based on the word length user picked
        wordModel.setCurrentWordSize(newSize: currentWordLength)
        currentWord = wordModel.randomWord
        while (wordModel.isDefined(currentWord) == false) {
            currentWord = wordModel.randomWord
        }
        currentWordInChar = [Character](currentWord)
        currentWordInChar.shuffle() //Randomly reorder the letters
        for i in 0...currentWordLength-1 {
            //Display each letter as a title of a segment
            letterPickSegmentCtrl.setTitle((String)(currentWordInChar[i]), forSegmentAt: i)
        }
        newWordButton.isEnabled = false
        roundCount += 1
    }
    
    //  When user pick a letter
    @IBAction func letterPickSelected(_ sender: UISegmentedControl) {
        if currentWordInChar.isEmpty == false {
            //Get the index of the segment user select
            let indexOfSelected : Int = letterPickSegmentCtrl.selectedSegmentIndex
            lastSelectedLetters.append(indexOfSelected)
            //Disable the segment user select
            letterPickSegmentCtrl.setEnabled(false, forSegmentAt: indexOfSelected)
            //Append the letter to user's answer string and display it in the userAnswer label
            userGuess += (String)(currentWordInChar[indexOfSelected])
            userAnswerLabel.text = userGuess
            undoButton.isEnabled = true
            if lastSelectedLetters.count == currentWordLength {
                checkButton.isEnabled = true
            }
        }
    }
    
    //  When user pick a word length
    @IBAction func wordLengthPickSelected(_ sender: UISegmentedControl) {
        //Change the word length based on user's selection
        switch wordLengthPickSegmentCtrl.selectedSegmentIndex {
        case 0:
            userAnswerLabel.text = ""
            currentWordLength = 4
            resetSegmentControl(wordLength: currentWordLength)
        case 1:
            userAnswerLabel.text = ""
            currentWordLength = 5
            resetSegmentControl(wordLength: currentWordLength)
        case 2:
            userAnswerLabel.text = ""
            currentWordLength = 6
            resetSegmentControl(wordLength: currentWordLength)
        default:
            break
        }
    }
    
    //  Clear all the segments and generate new segments according to current word length
    func resetSegmentControl(wordLength : Int) {
        letterPickSegmentCtrl.removeAllSegments()
        for _ in 1...wordLength {
            letterPickSegmentCtrl.insertSegment(withTitle: "", at: 0, animated: false) //Create a new segment
            letterPickSegmentCtrl.setEnabled(false, forSegmentAt: 0) //Disable them right now
        }
    }
    
}

