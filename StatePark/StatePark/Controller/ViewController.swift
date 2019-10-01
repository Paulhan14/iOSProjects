//
//  ViewController.swift
//  StatePark
//
//  Created by Jiaxing Han on 9/25/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//  National Park https://icons8.com/icons/set/national-park icon by Icons8 https://icons8.com
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    // MARK: Variables
    private let parksModel: ParkImageModel = ParkImageModel()
    private var parkScrollViews: [ParkScrollView] = []
    private let zoomView: UIScrollView = UIScrollView()
    private var zoomImageView: UIImageView = UIImageView()
    private var zoomImage: UIImage = UIImage()
    private var startScale: CGFloat = 0.0
    var arrowIcons: [String:UIImageView] = [:]
    var currentParkIndex: Int {return Int(mainScrollView.contentOffset.x / mainScrollView.bounds.width)}
    
    // MARK: View outlets
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initParkScrollView()
        addImageView()
        addArrowIcon()
        mainScrollView.showsHorizontalScrollIndicator = false
    }
    
    func initParkScrollView() {
        mainScrollView.delegate = self
        let size = mainScrollView.bounds.size
        mainScrollView.contentSize = CGSize(width: size.width * CGFloat(self.parksModel.getParkCount()), height: size.height)
        // Create vertical scroll views for each park
        for i in 0..<parksModel.getParkCount() {
            let origin = CGPoint(x: CGFloat(i) * size.width, y: 0.0)
            let frame = CGRect(origin: origin, size: CGSize(width: size.width, height: size.height))
            let name = parksModel.getParkNameAt(index: i)
            let parkView = ParkScrollView.init(parkName: name, frame: frame)
            self.mainScrollView.addSubview(parkView)
            let parkImageNames = self.parksModel.getImageNameOfPark(name: name)
            let parkImageCount = self.parksModel.getParkImageCountAt(index: i)
            parkView.initParkImages(imageNames: parkImageNames, imageCount: parkImageCount)
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoomImage(_:)))
            parkView.addGestureRecognizer(pinch)
            parkView.showsVerticalScrollIndicator = false
            parkView.delegate = self
            parkScrollViews.append(parkView)
        }
    }
    
    func addImageView() {
        // Add images to each scroll view
        for parkNum in 0..<parksModel.getParkCount() {
            let parkView = self.parkScrollViews[parkNum]
            let size = parkView.bounds.size
            parkView.contentSize = CGSize(width: size.width, height: size.height * CGFloat(parksModel.getParkImageCountAt(index: parkNum) + 1))
            parkView.isScrollEnabled = true
            parkView.isPagingEnabled = true
            let imageViews = parkView.getImages()
            // Add images
            for picNum in 0..<parksModel.getParkImageCountAt(index: parkNum) {
                let origin = CGPoint(x: 0.0, y: size.height * CGFloat(picNum+1))
                let frame = CGRect(origin: origin, size: CGSize(width: size.width, height: size.height))
                let aImage = imageViews[picNum]
                aImage.frame = frame
                aImage.contentMode = .scaleAspectFit
                self.parkScrollViews[parkNum].addSubview(aImage)
                self.parkScrollViews[parkNum].bringSubviewToFront(self.parkScrollViews[parkNum].parkLabel)
            }
        }
    }
    
    func addArrowIcon() {
        // Icons made by Smashicons https://www.flaticon.com/authors/smashicons from Flaticon https://www.flaticon.com/
        let upArrowIcon = UIImageView(image: UIImage(named: "uparrow"))
        self.view.addSubview(upArrowIcon)
        upArrowIcon.center = CGPoint(x: self.view.bounds.width/2.0, y: self.view.bounds.height/10.0)
        arrowIcons["up"] = upArrowIcon
        upArrowIcon.isHidden = true
        
        let downArrowIcon = UIImageView(image: UIImage(named: "downarrow"))
        self.view.addSubview(downArrowIcon)
        downArrowIcon.center = CGPoint(x: self.view.bounds.width/2.0, y: 9.0 * self.view.bounds.height/10.0)
        arrowIcons["down"] = downArrowIcon
        downArrowIcon.isHidden = true
        
        let rightArrowIcon = UIImageView(image: UIImage(named: "rightarrow"))
        self.view.addSubview(rightArrowIcon)
        rightArrowIcon.center = CGPoint(x: 9.0 * self.view.bounds.width/10.0, y: self.view.bounds.height/2.0)
        arrowIcons["right"] = rightArrowIcon
        rightArrowIcon.isHidden = true
        
        let leftArrowIcon = UIImageView(image: UIImage(named: "leftarrow"))
        self.view.addSubview(leftArrowIcon)
        leftArrowIcon.center = CGPoint(x: self.view.bounds.width/10.0, y: self.view.bounds.height/2.0)
        arrowIcons["left"] = leftArrowIcon
        leftArrowIcon.isHidden = true
    }
    
    @objc func zoomImage(_ sender: UIPinchGestureRecognizer) {
        let currentPark = parkScrollViews[currentParkIndex]
        if currentPark.currentImageIndex > -1 {
            switch sender.state {
            case .began:
                setupZoomView()
                self.view.addSubview(zoomView)
                self.view.bringSubviewToFront(zoomView)
            case .changed:
                if sender.scale > 1 {
                    zoomImageView.transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)
                }
            default:
                break
            }
        }
    }
    
    func setupZoomView() {
        //Init the zoom view
        let size = CGSize(width: mainScrollView.bounds.size.width, height: mainScrollView.bounds.size.height)
        let origin = mainScrollView.frame.origin
        let frame = CGRect(origin: origin, size: size)
        zoomView.frame = frame
        zoomView.backgroundColor = UIColor.white
        // Add the displayed image to this zoom view
        let currentPark = parkScrollViews[currentParkIndex]
        let currentImage = currentPark.currentImageIndex
        let imageNames = parksModel.getImageNameOfPark(name: currentPark.getParkName())
        zoomImage = UIImage(named: imageNames[currentImage])!
        zoomImageView = UIImageView(image: zoomImage)
        zoomView.contentSize = zoomImage.size
        zoomView.addSubview(zoomImageView)
        zoomImageView.frame.size = zoomImage.size
        let minScale = scaleFor(size: zoomImage.size)
        let scaleFrame = CGRect(origin: zoomImageView.frame.origin, size: CGSize(width: minScale * zoomImageView.frame.width, height: minScale * zoomImageView.frame.height))
        zoomImageView.frame = scaleFrame
        zoomImageView.center = CGPoint(x: zoomView.bounds.width/2.0, y: zoomView.bounds.height/2.0)
        zoomView.setZoomScale( 0.375, animated: false)
        zoomView.minimumZoomScale = 1.0
        zoomView.maximumZoomScale = 10.0
        zoomView.delegate = self
        startScale = zoomView.zoomScale
    }

    
    // MARK: Delegate functions
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Set horizontal scroll view enabled or disabled
        let currentPark = parkScrollViews[currentParkIndex]
        mainScrollView.isScrollEnabled = currentPark.isAllowedOrNot()
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        // "Remove" arrows
        setIndicators(up: true, down: true, left: true, right: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Add arrows based on the current page
        let currentPark = parkScrollViews[currentParkIndex]
        let imageIndex = currentPark.currentImageIndex
        let max = parksModel.getParkCount()-1
        // Update arrows
        switch currentParkIndex {
        case 0:
            if imageIndex == -1 {
                setIndicators(up: true, down: false, left: true, right: false)
            } else if imageIndex == currentPark.getImageCount() - 1{
                setIndicators(up: false, down: true, left: true, right: true)
            } else {
                setIndicators(up: false, down: false, left: true, right: true)
            }
        case max:
            if imageIndex == -1 {
                setIndicators(up: true, down: false, left: false, right: true)
            } else if imageIndex == currentPark.getImageCount() - 1{
                setIndicators(up: false, down: true, left: true, right: true)
            } else {
                setIndicators(up: false, down: false, left: true, right: true)
            }
        default:
            if imageIndex == -1 {
                setIndicators(up: true, down: false, left: false, right: false)
            } else if imageIndex == currentPark.getImageCount() - 1{
                setIndicators(up: false, down: true, left: true, right: true)
            } else {
                setIndicators(up: false, down: false, left: true, right: true)
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // When image view goes back to the normal scale, then remove the zoom view
        if scale == startScale{
            zoomImageView.removeFromSuperview()
            zoomView.removeFromSuperview()
        }
    }
    
    // Center the image view when zooming
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        // adjust the center of image view
        zoomImageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    // MARK: Helper function
    // Set arrow icons visibility
    func setIndicators(up: Bool, down: Bool, left: Bool, right: Bool) {
        self.arrowIcons["up"]!.isHidden = up
        self.arrowIcons["down"]!.isHidden = down
        self.arrowIcons["left"]!.isHidden = left
        self.arrowIcons["right"]!.isHidden = right
    }
    
    func scaleFor(size:CGSize) -> CGFloat {
        let viewSize = zoomView.bounds.size
        let widthScale = viewSize.width/size.width
        let heightScale = viewSize.height/size.height
        var minScale = min(widthScale,heightScale)
        if minScale > 1 {minScale = 1.0}
        return minScale
    }
}

