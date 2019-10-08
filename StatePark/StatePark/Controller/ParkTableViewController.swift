//
//  ParkTableViewController.swift
//  StatePark
//
//  Created by Jiaxing Han on 10/1/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class ParkTableViewController: UITableViewController {
    // model instance
    private let parksModel = ParkImageModel()
    // flag for each section
    private var collapsed = [Bool]()
    // full-screen image view
    private var scrollView = UIScrollView()
    private var imageView = UIImageView()
    private var imageToDisplay: UIImage? = nil
    private var thumbnailFrame = CGRect()
    // store device orientation
    private var orientation = UIDeviceOrientation.portrait
    // support
    private let animateDuration = 0.38
    private let titleWhite = UIColor(red: 246/255, green: 246/255, blue: 242/255, alpha: 1)
    private let titleGreenBlue = UIColor(red: 56/255, green: 128/255, blue: 135/255, alpha: 1)
    private let titleFont = UIFont.init(name: "Rockwell-Bold", size: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init collapsed array
        for _ in 0..<parksModel.getParkCount() {
            collapsed.append(false)
        }
        // set up scroll view
        scrollView.frame = self.view.frame
        scrollView.backgroundColor = .black
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
        // if device changed orientation, update full-screen image view
        if UIDevice.current.orientation != orientation {
            scrollView.frame = self.view.frame
            if imageToDisplay != nil {
                let minScale = scaleFor(size: imageToDisplay!.size)
                let scaleSize = CGSize(width: minScale * imageToDisplay!.size.width, height: minScale * imageToDisplay!.size.height)
                self.imageView.frame.size = scaleSize
            }
            self.imageView.center = CGPoint(x: self.scrollView.bounds.width/2.0, y: self.scrollView.bounds.height/2.0)
            orientation = UIDevice.current.orientation
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return parksModel.getParkCount()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // prevent this section from loading if it is collapsed
        if collapsed[section] {
            return 0
        }
        return parksModel.getParkImageCountAt(index: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkCells", for: indexPath) as! ParkTableViewCell
        // prevent this cell from loading if it is in collapsed section
        if collapsed[indexPath.section] {
            return cell
        }
        // configure cell
        let captions = parksModel.getCaptionsOfParkAt(index: indexPath.section)
        let imageNames = parksModel.getImageNameOfParkAt(index: indexPath.section)
        cell.captionLabel!.text = captions[indexPath.row]
        cell.ParkImageView!.image = UIImage(named: imageNames[indexPath.row])
        cell.ParkImageView!.layer.cornerRadius = 6.18
        return cell
    }
    
    // MARK: TableView header and cell custumization
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
        let label = UILabel()
        if collapsed[section] {
            label.text = "+ " + parksModel.getParkNameAt(index: section)
        } else {
            label.text = "- " + parksModel.getParkNameAt(index: section)
        }
        // configure title
        label.font = titleFont
        label.textColor = titleWhite
        headerView.addSubview(label)
        label.frame = CGRect(x: 10, y: 14, width: headerView.frame.width-10, height: headerView.frame.height-10)
        headerView.backgroundColor = titleGreenBlue
        let headerTapped = UITapGestureRecognizer(target: self, action: #selector(sectionHeaderTapped(recognizer:)))
        headerView.addGestureRecognizer(headerTapped)
        headerView.tag = section
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 49
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if collapsed[indexPath.section] {
            return 0
        }
        return 100
    }
    
    // Select row to display image
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.scrollView.isHidden = false
        self.view.bringSubviewToFront(scrollView)
        let selectedCell = tableView.cellForRow(at: indexPath) as! ParkTableViewCell
        let thumbnail = selectedCell.ParkImageView
        let thumbnailSuperView = thumbnail!.superview!
        // get the image
        let imageNames = parksModel.getImageNameOfParkAt(index: indexPath.section)
        imageToDisplay = UIImage(named: imageNames[indexPath.row])!
        imageView.image = imageToDisplay
        thumbnailFrame = thumbnailSuperView.convert(thumbnail!.frame, to: scrollView)
        scrollView.addSubview(imageView)
        imageView.frame = thumbnailFrame
        // center frame
        let minScale = scaleFor(size: imageToDisplay!.size)
        let scaleSize = CGSize(width: minScale * imageToDisplay!.size.width, height: minScale * imageToDisplay!.size.height)
        // set center frame
        UIView.animate(withDuration: animateDuration) {
            self.imageView.frame.size = scaleSize
            self.imageView.center = CGPoint(x: self.scrollView.bounds.width/2.0, y: self.scrollView.bounds.height/2.0)
        }
        
        scrollView.contentSize = imageToDisplay!.size
        self.tableView.isScrollEnabled = false
    }
    
    // MARK: Scroll View delegate
    override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        // adjust the center of image view
        imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    // MARK: Gesture response
    @objc func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        let section = recognizer.view!.tag
        collapsed[section] = !collapsed[section]
        let indexPath = IndexSet(integer: section)
        tableView.reloadSections(indexPath, with: .fade)
    }
    
    @objc func zoomImageTapped(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            UIView.animate(withDuration: animateDuration, animations: {
                self.imageView.frame = self.thumbnailFrame
            }) { (finished) in
                self.imageView.removeFromSuperview()
                self.imageView = UIImageView()
                self.scrollView.isHidden = true
                self.imageToDisplay = nil
                self.tableView.isScrollEnabled = true
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
