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
    let kMoveScaleFactor : CGFloat = 1.2
    let kSideOfSquare: CGFloat = 30.0
    var numberOfHintPressed: Int
    let piecesModel = PiecesModel()
    let solutionModel = Model()
    let piecesViews: [UIImageView]
    var singleTaps: [UITapGestureRecognizer] = []
    var doubleTaps: [UITapGestureRecognizer] = []
    var pans: [UIPanGestureRecognizer] = []
    var oldTransforms: [CGAffineTransform] = []
    var orientation: UIDeviceOrientation = UIDevice.current.orientation

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
            pieceImageView.isUserInteractionEnabled = true
            pieceImageView.tag = i
            _piecesViews.append(pieceImageView)
        }
        piecesViews = _piecesViews
        self.numberOfHintPressed = 0
        super.init(coder: aDecoder)
    }
    
    // viewDidLoad method
    override func viewDidLoad() {
        super.viewDidLoad()
        placePieces()
        initBoardButtonTags()
        doubleTapsInit()
        singleTapsInit()
        pansInit()
        
        for i in 0..<piecesModel.getPiecesCount() {
            let aPiece = self.piecesModel.pieces[i]
            aPiece.setOriginalX(x: Double(self.piecesViews[i].frame.origin.x))
            aPiece.setOriginalY(y: Double(self.piecesViews[i].frame.origin.y))
            aPiece.setWidth(width: Double(self.piecesViews[i].frame.size.width))
            aPiece.setHeight(height: Double(self.piecesViews[i].frame.size.height))
            piecesBoardView.addSubview(piecesViews[i])
            piecesViews[i].addGestureRecognizer(doubleTaps[i])
            piecesViews[i].addGestureRecognizer(singleTaps[i])
            piecesViews[i].addGestureRecognizer(pans[i])
        }
        
        solveButton.isEnabled = false
        resetButton.isEnabled = false
        hintButton.isEnabled = false
        solveButton.setTitleColor(UIColor.lightGray, for: .disabled)
        resetButton.setTitleColor(UIColor.lightGray, for: .disabled)
        hintButton.setTitleColor(UIColor.lightGray, for: .disabled)
        mainBoardImageView.isUserInteractionEnabled = true
    }
    
    // Prepare for the Hint popup
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "HintSegue":
            let hintViewController = segue.destination as! HintViewController
            let currentBoardType = solutionModel.getBoardType()
            let boards = BoardsModel()
            let boardName = boards.getBoardNameOf(index: currentBoardType)
            hintViewController.configure(boardName: boardName, solutionModel: self.solutionModel, numberOfPieces: self.numberOfHintPressed)
            hintViewController.closureBlock = {self.dismiss(animated: true, completion: nil)}
        default:
            break
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIDevice.current.orientation != self.orientation {
            placePieces()
            for i in 0..<piecesModel.getPiecesCount() {
                if piecesViews[i].superview == piecesBoardView {
                    let aPiece = self.piecesModel.pieces[i]
                    aPiece.setOriginalX(x: Double(self.piecesViews[i].frame.origin.x))
                    aPiece.setOriginalY(y: Double(self.piecesViews[i].frame.origin.y))
                    aPiece.setWidth(width: Double(self.piecesViews[i].frame.size.width))
                    aPiece.setHeight(height: Double(self.piecesViews[i].frame.size.height))
                }
            }
            self.orientation = UIDevice.current.orientation
        }
    }
    
    
    //  MARK:actions
    //  When board buttons are pressed
    @IBAction func BoardButtonPressed(_ sender: UIButton) {
        //  load board image to mian board view based on the selection
        loadBoardImage(sender.tag)
        if sender.tag != self.solutionModel.getBoardType() {
            self.numberOfHintPressed = 0
        }
        //  turns solve button and reset button on and off
        if sender.tag != 0 {
            solveButton.isEnabled = true
            hintButton.isEnabled = true
            solutionModel.setBoardType(type: sender.tag)
        } else {
            solutionModel.setBoardType(type: sender.tag)
            solveButton.isEnabled = false
            hintButton.isEnabled = false
            if mainBoardImageView.subviews.isEmpty {
                resetButton.isEnabled = false
            }
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
                self.piecesBoardView.addSubview(aPieceView)
                aPieceView.frame = frame
            }
        }) { (finished) in
            if self.solutionModel.getBoardType() != 0 {
                self.solveButton.isEnabled = true
            }
            for button in self.boardButtons {
                button.isEnabled = true
            }
        }
    }
    
    @IBAction func hintPressed(_ sender: UIButton) {
        if self.numberOfHintPressed < 12 {
            self.numberOfHintPressed += 1
        }
    }
    
    // MARK: Gesture Respond
    @objc func rotatePiece(_ sender:UITapGestureRecognizer) {
        if sender.state == .ended {
            if sender.view!.superview == self.mainBoardImageView {
                UIView.animate(withDuration: 0.3) {
                    let pieceView = sender.view!
                    let rotationDegree = self.degreeToRadian(1)
                    let transform = CGAffineTransform(rotationAngle: rotationDegree)
                    pieceView.transform = pieceView.transform.concatenating(transform)
                    let x = pieceView.frame.origin.x / self.kSideOfSquare
                    let y = pieceView.frame.origin.y / self.kSideOfSquare
                    let newX = round(x) * self.kSideOfSquare
                    let newY = round(y) * self.kSideOfSquare
                    pieceView.frame = CGRect(x: newX, y: newY, width: pieceView.frame.size.width, height: pieceView.frame.size.height)
                }
            }
        }
    }
    
    @objc func flipPiece(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if sender.view!.superview == self.mainBoardImageView {
                UIView.animate(withDuration: 0.3) {
                    let transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                    sender.view!.transform = sender.view!.transform.concatenating(transform)
                }
            }
        }
    }
    
     @objc func movePiece(_ sender: UIPanGestureRecognizer) {
        if let pieceView = sender.view as? UIImageView {
            let location = sender.location(in: self.view)
            let aPiece = self.piecesModel.getAPiece(index: pieceView.tag)
            
            switch sender.state {
            case .began:
                let newFrame = self.view.convert(pieceView.frame, from: pieceView.superview)
                pieceView.frame = newFrame
                self.view.addSubview(pieceView)
                self.view.bringSubviewToFront(pieceView)
                let transform = CGAffineTransform(scaleX: kMoveScaleFactor, y: kMoveScaleFactor)
                pieceView.transform = pieceView.transform.concatenating(transform)
            case .changed:
                pieceView.center = location
            case .ended:
                pieceView.transform = pieceView.transform.scaledBy(x: 1/kMoveScaleFactor, y: 1/kMoveScaleFactor)
                resetButton.isEnabled = true
                if mainBoardImageView.frame.contains(pieceView.frame) {
                    pieceView.frame = self.mainBoardImageView.convert(pieceView.frame, from: pieceView.superview)
                    mainBoardImageView.addSubview(pieceView)
                    mainBoardImageView.bringSubviewToFront(pieceView)
                    let x = pieceView.frame.origin.x / kSideOfSquare
                    let y = pieceView.frame.origin.y / kSideOfSquare
                    let newX = round(x) * kSideOfSquare
                    let newY = round(y) * kSideOfSquare
                    pieceView.frame = CGRect(x: newX, y: newY, width: pieceView.frame.size.width, height: pieceView.frame.size.height)
                } else {
                    UIView.animate(withDuration: kAnimationDuration) {
                        let newOrigin = self.piecesBoardView.convert(pieceView.frame.origin, from: self.mainBoardImageView)
                        pieceView.frame.origin = newOrigin
                        let frame = CGRect(x: aPiece.originalX, y: aPiece.originalY, width: aPiece.width, height: aPiece.height)
                        pieceView.frame = frame
                        pieceView.transform = CGAffineTransform.identity
                        self.piecesBoardView.addSubview(pieceView)
                    }
                }
            default:
                break
            }
        }
    }
    
    //  MARK:Helper Functions
    //  Place each piece on the board
    func placePieces() {
        let widthOfEach = 100
        let xOffset = 15
        let xIncrementValue = 110
        let yOffset = 10
        let yIncrementValue = 190
        let widthOfBoard = piecesBoardView.frame.width
        let numberOfPiecesOneLine = Int(widthOfBoard) / widthOfEach
        let numberOfLines = piecesModel.getPiecesCount() / numberOfPiecesOneLine
        let lastLine = piecesModel.getPiecesCount() % numberOfPiecesOneLine
        //  Handles pentomino pieces except last row
        for i in 0..<numberOfLines {
            for j in 0..<numberOfPiecesOneLine {
                let aPieceView = piecesViews[j + i * numberOfPiecesOneLine]
                if aPieceView.superview == self.piecesBoardView {
                    let x = CGFloat(j * xIncrementValue + xOffset)
                    let y = CGFloat(yOffset + yIncrementValue * i)
                    let width = aPieceView.frame.width
                    let height = aPieceView.frame.height
                    let frame = CGRect(x: x, y: y, width: width, height: height)
                    aPieceView.frame = frame
                }
            }
        }
        //  If last row has pieces in it
        if lastLine != 0 {
            for i in 0..<lastLine {
                let aPieceView = piecesViews[i + numberOfLines * numberOfPiecesOneLine]
                if aPieceView.superview == self.piecesBoardView {
                    let x = CGFloat(i * xIncrementValue + xOffset)
                    let y = CGFloat(yIncrementValue * numberOfLines)
                    let width = aPieceView.frame.width
                    let height = aPieceView.frame.height
                    let frame = CGRect(x: x, y: y, width: width, height: height)
                    aPieceView.frame = frame
                }
            }
        }
    }
    
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
    
    func singleTapsInit() {
        var _singleTaps: [UITapGestureRecognizer] = []
        for i in 0..<piecesModel.getPiecesCount() {
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(rotatePiece(_:)))
            singleTap.numberOfTapsRequired = 1
            singleTap.require(toFail: doubleTaps[i])
            _singleTaps.append(singleTap)
        }
        singleTaps = _singleTaps
    }
    
    func doubleTapsInit() {
        var _doubleTaps: [UITapGestureRecognizer] = []
        for _ in 0..<piecesModel.getPiecesCount() {
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(flipPiece(_:)))
            doubleTap.numberOfTapsRequired = 2
            _doubleTaps.append(doubleTap)
        }
        doubleTaps = _doubleTaps
    }
    
    func pansInit() {
        var _pans: [UIPanGestureRecognizer] = []
        for _ in 0..<piecesModel.getPiecesCount() {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(movePiece(_:)))
            _pans.append(pan)
        }
        pans = _pans
    }
}
