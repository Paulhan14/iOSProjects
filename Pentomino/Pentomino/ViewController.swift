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
    let piecesModel = PiecesModel()
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
            let pieceName = piecesModel.getPieceNameAt(index: i)
            let pieceImageView = UIImageView(image: UIImage(named: pieceName))
            _piecesViews.append(pieceImageView)
        }
        piecesViews = _piecesViews
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBoardButtonTags()
        for aImage in piecesViews {
            piecesBoardView.addSubview(aImage)
        }
        positionPiece()
    }
    

    //  MARK:actions
    @IBAction func BoardButtonPressed(_ sender: UIButton) {
        loadBoardImage(sender.tag)
    }
    
    //  Other functions
    func loadBoardImage(_ label:Int) {
        mainBoardImageView.image = UIImage(named:"Board\(label)")
    }
    
    func positionPiece() {
        for i in 0..<6 {
            let aPiece = piecesViews[i]
            let x = CGFloat(i * 120)
            let y = CGFloat(30)
            let frame = CGRect(x: x, y: y, width: aPiece.frame.width, height: aPiece.frame.height)
            aPiece.frame = frame
        }
        
        for i in 0..<6 {
            let aPiece = piecesViews[i+6]
            let x = CGFloat(i * 120)
            let y = CGFloat(225)
            let frame = CGRect(x: x, y: y, width: aPiece.frame.width, height: aPiece.frame.height)
            aPiece.frame = frame
        }
    }
    
    func initBoardButtonTags() {
        var i = 0
        for button in boardButtons {
            button.tag = i
            i += 1
        }
    }
    

}

