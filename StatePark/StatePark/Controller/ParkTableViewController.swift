//
//  ParkTableViewController.swift
//  StatePark
//
//  Created by Jiaxing Han on 10/1/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class ParkTableViewController: UITableViewController {
    
    private let parksModel = ParkImageModel()
    private var collapsed = [Bool]()
    private var scrollView = UIScrollView()
    private var imageView = UIImageView()
    private var thumbnailFrame = CGRect()
    private var orientation = UIDeviceOrientation.portrait
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        for _ in 0..<parksModel.getParkCount() {
            collapsed.append(false)
        }
        scrollView.frame = self.view.frame
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
            scrollView.frame = self.view.frame
            self.imageView.center = CGPoint(x: self.scrollView.bounds.width/2.0, y: self.scrollView.bounds.height/2.0)
            orientation = UIDevice.current.orientation
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return parksModel.getParkCount()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if collapsed[section] {
            return 0
        }
        return parksModel.getParkImageCountAt(index: section)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkCells", for: indexPath) as! ParkTableViewCell
        
        if collapsed[indexPath.section] {
            return cell
        }
        
        let captions = parksModel.getCaptionsOfParkAt(index: indexPath.section)
        let imageNames = parksModel.getImageNameOfParkAt(index: indexPath.section)
        cell.captionLabel!.text = captions[indexPath.row]
        cell.ParkImageView!.image = UIImage(named: imageNames[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
        let label = UILabel()
        if collapsed[section] {
            label.text = "+ " + parksModel.getParkNameAt(index: section)
        } else {
            label.text = "- " + parksModel.getParkNameAt(index: section)
        }
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor(red: 188/255, green: 143/255, blue: 143/255, alpha: 1)
        headerView.addSubview(label)
        label.frame = CGRect(x: 10, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        headerView.backgroundColor = UIColor(red: 232/255, green: 233/255, blue: 243/255, alpha: 1)
        let headerTapped = UITapGestureRecognizer(target: self, action: #selector(sectionHeaderTapped(recognizer:)))
        headerView.addGestureRecognizer(headerTapped)
        headerView.tag = section
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if collapsed[indexPath.section] {
            return 0
        }
        
        return 100
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.scrollView.isHidden = false
        self.view.bringSubviewToFront(scrollView)
        let selectedCell = tableView.dequeueReusableCell(withIdentifier: "ParkCells", for: indexPath) as! ParkTableViewCell
        let thumbnail = selectedCell.ParkImageView
        let thumbnailSuperView = thumbnail!.superview!
        
        // get the image
        let imageNames = parksModel.getImageNameOfParkAt(index: indexPath.section)
        let imageToDisplay = UIImage(named: imageNames[indexPath.row])
        imageView.image = imageToDisplay
        thumbnailFrame = thumbnailSuperView.convert(thumbnail!.frame, to: scrollView)
        scrollView.addSubview(imageView)
        imageView.frame = thumbnailFrame
        // center frame
        let minScale = scaleFor(size: imageToDisplay!.size)
        let scaleFrame = CGRect(origin: imageView.frame.origin, size: CGSize(width: minScale * imageToDisplay!.size.width, height: minScale * imageToDisplay!.size.height))
        // set center frame
        UIView.animate(withDuration: 0.38) {
            self.imageView.frame = scaleFrame
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
            UIView.animate(withDuration: 0.38, animations: {
                self.imageView.frame = self.thumbnailFrame
            }) { (finished) in
                self.imageView.removeFromSuperview()
                self.imageView = UIImageView()
                self.scrollView.isHidden = true
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
