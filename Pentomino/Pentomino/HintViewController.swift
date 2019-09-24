//
//  HintViewController.swift
//  Pentomino
//
//  Created by Jiaxing Han on 9/23/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class HintViewController: UIViewController {

    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var boardImageView: UIImageView!
    var boardName: String?
    var closureBlock: (() -> Void)?
    var solutionModel: Model? = nil
    var numberOfPieces: Int?
    var pieces: [UIImageView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let boardImage = UIImage(named: boardName!)
        boardImageView.image = boardImage
        
        for i in 0..<numberOfPieces! {
            let piecesModel = PiecesModel()
            let aPiece = piecesModel.getAPiece(index: i)
            let pieceName = aPiece.generateName()
            let pieceImage = UIImage(named: pieceName)
            var pieceView = UIImageView(image: pieceImage)
            let position = self.solutionModel!.findSolutionForPiece(name: aPiece.shape)
            pieceView = setPieceWithSolution(pieceView, position)
            boardImageView.addSubview(pieceView)
        }
    }
    
    func configure(boardName: String, solutionModel: Model, numberOfPieces: Int) {
        self.boardName = boardName
        self.solutionModel = solutionModel
        self.numberOfPieces = numberOfPieces
    }

    @IBAction func dismissHint(_ sender: UIButton) {
        if let _block = closureBlock {
            _block()
        }
    }
    
    func setPieceWithSolution(_ pieceView: UIImageView,_ position: Position) -> UIImageView {
        let gridSize = 30.0
        //  Rotation and then flip, if necessary
        let rotationDegree = self.degreeToRadian(position.rotations)
        var transform = CGAffineTransform(rotationAngle: rotationDegree)
        if position.isFlipped {
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        }
        pieceView.transform = transform
        //  Generate new frame based on the updated information
        let x = CGFloat(Double(position.x) * gridSize)
        let y = CGFloat(Double(position.y) * gridSize)
        let width = pieceView.frame.width
        let height = pieceView.frame.height
        let frame = CGRect(x: x, y: y, width: width, height: height)
        pieceView.frame = frame
        return pieceView
    }
    
    //  Convert degrees to radians
    func degreeToRadian(_ numberOf90Degree: Int) -> CGFloat {
        return CGFloat(Double(numberOf90Degree) * .pi / 2)
    }
}
