//
//  ViewController.swift
//  Pentomino
//
//  Created by Jiaxing Han on 9/12/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //  MARK:variables and objects
    let kAnimationDuration = 1.0
    let piecesModel = PiecesModel()
    let solutionModel = Model()
    let piecesViews: [UIImageView]

    //  MARK:Buttons
    @IBOutlet var boardButtons: [UIButton]!
    @IBOutlet weak var solveButton: UIButton!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    //  MARK:views
    @IBOutlet weak var mainBoardImageView: UIImageView!
    @IBOutlet weak var piecesBoardView: UIView!
    
    // Initializer
    required init?(coder aDecoder: NSCoder) {
        var _piecesViews: [UIImageView] = []
        for i in 0..<piecesModel.getPiecesCount() {
            let pieceName = piecesModel.pieces[i].generateName()
            let image = UIImage(named: pieceName)
            let pieceImageView = UIImageView(image: image)
            _piecesViews.append(pieceImageView)
        }
        piecesViews = _piecesViews
        super.init(coder: aDecoder)
    }
    
    // viewDidLoad method
    override func viewDidLoad() {
        super.viewDidLoad()
        initBoardButtonTags()
        for aPieceView in piecesViews {
            piecesBoardView.addSubview(aPieceView)
        }
        solveButton.isEnabled = false
        resetButton.isEnabled = false
        solveButton.setTitleColor(UIColor.lightGray, for: .disabled)
        resetButton.setTitleColor(UIColor.lightGray, for: .disabled)
    }
    
    //  Place each piece on the board
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let widthOfEach = 120
        let xOffset = 30
        let xIncrementValue = 110
        let yOffset = 30
        let yIncrementValue = 180
        let widthOfBoard = piecesBoardView.frame.width
        let numberOfPiecesOneLine = Int(widthOfBoard) / widthOfEach
        let numberOfLines = piecesModel.getPiecesCount() / numberOfPiecesOneLine
        let lastLine = piecesModel.getPiecesCount() % numberOfPiecesOneLine
        //  Handles pentomino pieces except last row
        for i in 0..<numberOfLines {
            for j in 0..<numberOfPiecesOneLine {
                let aPieceView = piecesViews[j + i * numberOfPiecesOneLine]
                let x = CGFloat(j * xIncrementValue + xOffset)
                let y = CGFloat(yOffset + yIncrementValue * i)
                let width = aPieceView.frame.width
                let height = aPieceView.frame.height
                let frame = CGRect(x: x, y: y, width: width, height: height)
                aPieceView.frame = frame
            }
        }
        //  If last row has pieces in it
        if lastLine != 0 {
            for i in 0..<lastLine {
                let aPieceView = piecesViews[i + numberOfLines * numberOfPiecesOneLine]
                let x = CGFloat(i * xIncrementValue + xOffset)
                let y = CGFloat(yIncrementValue * numberOfLines)
                let width = aPieceView.frame.width
                let height = aPieceView.frame.height
                let frame = CGRect(x: x, y: y, width: width, height: height)
                aPieceView.frame = frame
            }
        }
    }
    
    //  MARK:actions
    //  When board buttons are pressed
    @IBAction func BoardButtonPressed(_ sender: UIButton) {
        //  load board image to mian board view based on the selection
        loadBoardImage(sender.tag)
        //  turns solve button and reset button on and off
        if sender.tag != 0 {
            solveButton.isEnabled = true
            solutionModel.setBoardType(type: sender.tag)
        } else {
            solveButton.isEnabled = false
            resetButton.isEnabled = false
        }
    }
    //  When solve button is pressed
    @IBAction func solvePressed(_ sender: UIButton) {
        //  Disable buttons
        for button in boardButtons {
            button.isEnabled = false
        }
        self.solveButton.isEnabled = false
        //  Handles transformation
        UIView.animate(withDuration: kAnimationDuration, animations: {
            for i in 0..<self.piecesModel.getPiecesCount() {
                let gridSize = 30.0
                let aPiece = self.piecesModel.pieces[i]
                let shape = aPiece.shape
                let position = self.solutionModel.findSolutionForPiece(name: shape)
                let rotationDegree = self.degreeToRadian(position.rotations)
                //  Back up original origin and size values
                aPiece.setOriginalX(x: Double(self.piecesViews[i].frame.origin.x))
                aPiece.setOriginalY(y: Double(self.piecesViews[i].frame.origin.y))
                aPiece.setWidth(width: Double(self.piecesViews[i].frame.size.width))
                aPiece.setHeight(height: Double(self.piecesViews[i].frame.size.height))
                //  Rotation and then flip, if necessary
                var transform = CGAffineTransform(rotationAngle: rotationDegree)
                if position.isFlipped {
                    transform = transform.scaledBy(x: -1.0, y: 1.0)
                }
                self.piecesViews[i].transform = transform
                //  Generate new frame based on the updated information
                let x = CGFloat(Double(position.x) * gridSize)
                let y = CGFloat(Double(position.y) * gridSize)
                let width = self.piecesViews[i].frame.width
                let height = self.piecesViews[i].frame.height
                let frame = CGRect(x: x, y: y, width: width, height: height)
                //  Convert to main board
                let convert = self.mainBoardImageView.convert(frame, to: self.piecesBoardView)
                self.piecesViews[i].frame = convert
            }
        }) { (finished) in
            self.resetButton.isEnabled = true
        }
    }
    
    //  When reset is pressed
    @IBAction func resetPressed(_ sender: Any) {
        // Disable itself
        self.resetButton.isEnabled = false
        //  Handles transformation
        UIView.animate(withDuration: kAnimationDuration, animations: {
            for i in 0..<self.piecesModel.getPiecesCount() {
                let aPiece = self.piecesModel.pieces[i]
                let aPieceView = self.piecesViews[i]
                //  Use back-up information to reconstruct frame
                let x = aPiece.originalX
                let y = aPiece.originalY
                let width = aPiece.width
                let height = aPiece.height
                let frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height))
                aPieceView.transform = CGAffineTransform.identity
                aPieceView.frame = frame
            }
        }) { (finished) in
            self.solveButton.isEnabled = true
            for button in self.boardButtons {
                button.isEnabled = true
            }
        }
    }
    
    //  MARK:Helper Functions
    //  Load board image to main board
    func loadBoardImage(_ label:Int) {
        let boards = BoardsModel()
        let image = UIImage(named:boards.getBoardNameOf(index: label))
        mainBoardImageView.image = image
    }
    //  Assign a tag to each of the board buttons
    func initBoardButtonTags() {
        var i = 0
        for button in boardButtons {
            button.tag = i
            i += 1
        }
    }
    //  Convert degrees to radians
    func degreeToRadian(_ numberOf90Degree: Int) -> CGFloat {
        return CGFloat(Double(numberOf90Degree) * .pi / 2)
    }

}

