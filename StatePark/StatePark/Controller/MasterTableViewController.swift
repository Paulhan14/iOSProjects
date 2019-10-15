//
//  MasterTableViewController.swift
//  StatePark
//
//  Created by Jiaxing Han on 10/9/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    // model instance
    private let parksModel = ParkImageModel()
    // flag for each section
    private var collapsed = [Bool]()
    // Appearance customization
    private let titleWhite = UIColor(red: 246/255, green: 246/255, blue: 242/255, alpha: 1)
    private let titleGreenBlue = UIColor(red: 56/255, green: 128/255, blue: 135/255, alpha: 1)
    private let titleFont = UIFont.init(name: "Rockwell-Bold", size: 20)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init collapsed array
        for _ in 0..<parksModel.getParkCount() {
            collapsed.append(false)
        }
        // Bring up detail view
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        displayIntro()
    }
    
    func displayIntro() {
        let userDefaults = UserDefaults.standard
        let displayed = userDefaults.bool(forKey: "Displayed")
        // IF USER HAVE CLICKED START BUTTON ONCE, DON'T DISPLAY
        if !displayed {
            if let pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") {
                self.present(pageViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                let captions = parksModel.getCaptionsOfParkAt(index: indexPath.section)
                let imageName = parksModel.getImageNameOfParkAt(index: indexPath.section)
                controller.captionLabelText = captions[indexPath.row]
                controller.parkImageName = imageName[indexPath.row]
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkSplitViewCell", for: indexPath) as! ParkTableViewCell
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
    
    // MARK: Gesture response
    @objc func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        let section = recognizer.view!.tag
        collapsed[section] = !collapsed[section]
        let indexPath = IndexSet(integer: section)
        tableView.reloadSections(indexPath, with: .fade)
    }
    
}
