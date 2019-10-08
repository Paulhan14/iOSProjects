//
//  ParkCollectionViewController.swift
//  StatePark
//
//  Created by Jiaxing Han on 10/3/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ParkCollectionViewController: UICollectionViewController {
    
    private let parksModel = ParkImageModel()
    // Full-screen image
    private var scrollView = UIScrollView()
    private var imageView = UIImageView()
    private var imageToDisplay: UIImage? = nil
    private var thumbnailFrame = CGRect()
    // Check device orientation
    private var orientation = UIDeviceOrientation.portrait
    // support
    private let animateDuration = 0.38
    private let titleWhite = UIColor(red: 246/255, green: 246/255, blue: 242/255, alpha: 1)
    private let titleGreenBlue = UIColor(red: 56/255, green: 128/255, blue: 135/255, alpha: 1)
    private let titleFont = UIFont.init(name: "Rockwell-Bold", size: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // set up the scroll view
        scrollView.frame = self.view.bounds
        scrollView.backgroundColor = .black
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.delegate = self
        let tapClose = UITapGestureRecognizer(target: self, action: #selector(zoomImageTapped(recognizer:)))
        scrollView.addGestureRecognizer(tapClose)
        UIApplication.shared.keyWindow!.addSubview(scrollView)
        scrollView.isHidden = true
        // store current orientation
        orientation = UIDevice.current.orientation
    }
    
    override func viewDidLayoutSubviews() {
        if UIDevice.current.orientation != orientation {
            scrollView.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
            if imageToDisplay != nil {
                let minScale = scaleFor(size: imageToDisplay!.size)
                let scaleSize = CGSize(width: minScale * imageToDisplay!.size.width, height: minScale * imageToDisplay!.size.height)
                self.imageView.frame.size = scaleSize
            }
            self.imageView.center = CGPoint(x: self.scrollView.bounds.width/2.0, y: self.scrollView.bounds.height/2.0)
            orientation = UIDevice.current.orientation
        }
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return parksModel.getParkCount()
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return parksModel.getParkImageCountAt(index: section)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParkCollectionCell", for: indexPath) as! ParkCollectionViewCell
        
        let imageNames = parksModel.getImageNameOfParkAt(index: indexPath.section)
        cell.parkCollectionImage!.image = UIImage(named: imageNames[indexPath.row])
        cell.parkCollectionImage!.layer.cornerRadius = 8
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ParkCollectionHeader", for: indexPath) as! ParkCollectionReusableView
            headerView.parkCollectionHeaderLabel!.text =  " " + parksModel.getParkNameAt(index: indexPath.section)
            headerView.parkCollectionHeaderLabel!.font = titleFont
            headerView.parkCollectionHeaderLabel!.textColor = titleWhite
            headerView.backgroundColor = titleGreenBlue
            return headerView
        default:
            assert(false, "Unhandled Element Kind")
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        scrollView.isHidden = false
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ParkCollectionViewCell
        let thumbnail = selectedCell.parkCollectionImage
        let thumbnailSuperView = thumbnail!.superview!
        // Get image
        let imageNames = parksModel.getImageNameOfParkAt(index: indexPath.section)
        imageToDisplay = UIImage(named: imageNames[indexPath.row])
        imageView.image = imageToDisplay
        thumbnailFrame = thumbnailSuperView.convert(thumbnail!.frame, to: scrollView)
        scrollView.addSubview(imageView)
        imageView.frame = thumbnailFrame
        // center frame
        let minScale = scaleFor(size: imageToDisplay!.size)
        let scaleFrame = CGRect(origin: imageView.frame.origin, size: CGSize(width: minScale * imageToDisplay!.size.width, height: minScale * imageToDisplay!.size.height))
        UIView.animate(withDuration: animateDuration) {
            self.imageView.frame = scaleFrame
            self.imageView.center = CGPoint(x: self.scrollView.bounds.width/2.0, y: self.scrollView.bounds.height/2.0)

        }
        scrollView.contentSize = imageToDisplay!.size
        self.view.bringSubviewToFront(scrollView)
    }
    
    // MARK: ScrollView Delegate
    override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        // adjust the center of image view
        imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    // MARK: Gesture respond
    @objc func zoomImageTapped(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            UIView.animate(withDuration: animateDuration, animations: {
                self.imageView.frame = self.thumbnailFrame
            }) { (finished) in
                self.imageView.removeFromSuperview()
                self.imageView = UIImageView()
                self.imageToDisplay = nil
                self.scrollView.isHidden = true
            }
        }
    }

    // MARK: Helper
    func scaleFor(size:CGSize) -> CGFloat {
        let viewSize = self.view.bounds.size
        let widthScale = viewSize.width/size.width
        let heightScale = viewSize.height/size.height
        return min(widthScale,heightScale)
    }
}
