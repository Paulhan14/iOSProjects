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
    private var thumbnailFrame = CGRect()
    // Check device orientation
    private var orientation = UIDeviceOrientation.portrait
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        scrollView.frame = self.view.bounds
        scrollView.backgroundColor = .white
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.delegate = self
        let tapClose = UITapGestureRecognizer(target: self, action: #selector(zoomImageTapped(recognizer:)))
        scrollView.addGestureRecognizer(tapClose)
        UIApplication.shared.keyWindow!.addSubview(scrollView)
        scrollView.isHidden = true
        orientation = UIDevice.current.orientation
    }
    
    override func viewDidLayoutSubviews() {
        if UIDevice.current.orientation != orientation {
            scrollView.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
            orientation = UIDevice.current.orientation
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ParkCollectionHeader", for: indexPath) as! ParkCollectionReusableView
            headerView.parkCollectionHeaderLabel!.text = parksModel.getParkNameAt(index: indexPath.section)
            headerView.parkCollectionHeaderLabel!.textColor = UIColor(red: 188/255, green: 143/255, blue: 143/255, alpha: 1)
            headerView.backgroundColor = UIColor(red: 232/255, green: 233/255, blue: 243/255, alpha: 1)
            return headerView
        default:
            assert(false, "Unhandled Element Kind")
        }
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        scrollView.isHidden = false
        let selectedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParkCollectionCell", for: indexPath) as! ParkCollectionViewCell
        let thumbnail = selectedCell.parkCollectionImage
        let thumbnailSuperView = thumbnail!.superview!
        
        // Get image
        let imageNames = parksModel.getImageNameOfParkAt(index: indexPath.section)
        let imageToDisplay = UIImage(named: imageNames[indexPath.row])
        imageView.image = imageToDisplay
        thumbnailFrame = thumbnailSuperView.convert(thumbnail!.frame, to: scrollView)
        scrollView.addSubview(imageView)
        imageView.frame = thumbnailFrame
        // center frame
        let minScale = scaleFor(size: imageToDisplay!.size)
        let scaleFrame = CGRect(origin: imageView.frame.origin, size: CGSize(width: minScale * imageView.frame.width, height: minScale * imageView.frame.height))
        UIView.animate(withDuration: 0.38) {
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
            UIView.animate(withDuration: 0.38, animations: {
                self.imageView.frame = self.thumbnailFrame
            }) { (finished) in
                self.imageView.removeFromSuperview()
                self.imageView = UIImageView()
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
