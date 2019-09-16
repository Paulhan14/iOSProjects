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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let widthOfBoard = piecesBoardView.frame.width
        let numberOfPiecesOneLine = Int(widthOfBoard / 120)
        let numberOfLines = piecesModel.getPiecesCount() / numberOfPiecesOneLine
        let lastLine = piecesModel.getPiecesCount() % numberOfPiecesOneLine
        
        for i in 0..<numberOfLines {
            for j in 0..<numberOfPiecesOneLine {
                let aPieceView = piecesViews[j + i * numberOfPiecesOneLine]
                let x = CGFloat(j * 100 + 30)
                let y = CGFloat(30 + 180 * i)
                let width = aPieceView.frame.width
                let height = aPieceView.frame.height
                let frame = CGRect(x: x, y: y, width: width, height: height)
                aPieceView.frame = frame
            }
        }
        
        if lastLine != 0 {
            for i in 0..<lastLine {
                let aPieceView = piecesViews[i + numberOfLines * numberOfPiecesOneLine]
                let x = CGFloat(i * 100 + 30)
                let y = CGFloat(210 * numberOfLines)
                let width = aPieceView.frame.width
                let height = aPieceView.frame.height
                let frame = CGRect(x: x, y: y, width: width, height: height)
                aPieceView.frame = frame
            }
        }
    }
    

    //  MARK:actions
    @IBAction func BoardButtonPressed(_ sender: UIButton) {
        loadBoardImage(sender.tag)
        if sender.tag != 0 {
            solveButton.isEnabled = true
            solutionModel.setBoardType(type: sender.tag)
        } else {
            solveButton.isEnabled = false
            resetButton.isEnabled = false
        }
    }
    
    @IBAction func solvePressed(_ sender: UIButton) {
        for button in boardButtons {
            button.isEnabled = false
        }
        self.solveButton.isEnabled = false
        UIView.animate(withDuration: kAnimationDuration, animations: {
            for i in 0..<self.piecesModel.getPiecesCount() {
                let aPiece = self.piecesModel.pieces[i]
                let shape = aPiece.shape
                let position = self.solutionModel.findSolutionForPiece(name: shape)
                let rotationDegree = self.degreeToRadian(position.rotations)
                aPiece.setOriginalX(x: Double(self.piecesViews[i].frame.origin.x))
                aPiece.setOriginalY(y: Double(self.piecesViews[i].frame.origin.y))
                aPiece.setWidth(width: Double(self.piecesViews[i].frame.size.width))
                aPiece.setHeight(height: Double(self.piecesViews[i].frame.size.height))
                
                var transform = CGAffineTransform.identity
                if position.isFlipped {
                    transform = transform.scaledBy(x: 1.0, y: -1.0)
                }
                self.piecesViews[i].transform = transform.rotated(by: rotationDegree)
                
                let x = CGFloat(Double(position.x) * 30.0)
                let y = CGFloat(Double(position.y) * 30.0)
                let width = self.piecesViews[i].frame.width
                let height = self.piecesViews[i].frame.height
                let frame = CGRect(x: x, y: y, width: width, height: height)
                
                let convert = self.mainBoardImageView.convert(frame, to: self.piecesBoardView)
                self.piecesViews[i].frame = convert
            }
        }) { (finished) in
            self.resetButton.isEnabled = true
        }
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        self.resetButton.isEnabled = false
        UIView.animate(withDuration: kAnimationDuration, animations: {
            for i in 0..<self.piecesModel.getPiecesCount() {
                let aPiece = self.piecesModel.pieces[i]
                let aPieceView = self.piecesViews[i]
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
    
    //  Other functions
    func loadBoardImage(_ label:Int) {
        let image = UIImage(named:"Board\(label)")
        mainBoardImageView.image = image
    }
    
    func initBoardButtonTags() {
        var i = 0
        for button in boardButtons {
            button.tag = i
            i += 1
        }
    }
    
    func degreeToRadian(_ numberOf90Degree: Int) -> CGFloat {
        return CGFloat(Double(numberOf90Degree) * .pi / 2)
    }

}

