//
//  PostsTableViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/9/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import CoreData

class PostsTableViewController: UITableViewController, DataSourceCellConfigurer {
    @IBOutlet weak var composeButton: UIBarButtonItem!
    
    lazy var dataSource : DataSource = DataSource(entity: "Post", sortKeys: ["time"], predicate: nil, sectionNameKeyPath: "time")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.delegate = self
        dataSource.tableView = self.tableView
        tableView.dataSource = dataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func configureCell(_ cell: UITableViewCell, withObject object: NSManagedObject) {
        let post = object as! Post
        let myPostCell = cell as! MyPostViewCell
        myPostCell.postField.text = post.text

        if let imageData = post.image {
            if imageData.description != "0 bytes" {
                myPostCell.imageWidth.constant = 134
                myPostCell.myImageView.image = ImageManager.shared.convertToImage(data: imageData)
            } else {
                myPostCell.imageWidth.constant = 0
            }
        } else {
            myPostCell.imageWidth.constant = 0
        }
        
        if let weather = post.weather {
            var weatherImage = UIImage()
            weatherImage = UIImage(named: weather)!
            myPostCell.weatherImage.image = weatherImage
            myPostCell.weatherLabel.text = weather
        }
        
        if let stepCount = post.steps {
            myPostCell.stepLabel.text = stepCount
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postView = storyboard!.instantiateViewController(withIdentifier: Constant.StoryBoardID.postView)
        let singleView = postView.children[0] as! PostViewController
        singleView.closureBlock =  {self.dismiss(animated: true, completion: nil)}
        singleView.postToShow = dataSource.objectAtIndexPath(indexPath) as? Post
        singleView.segueType = "My"
        self.present(postView, animated: true, completion: nil)
    }
    
    
    // MARK: - Buttons
    
    @IBAction func composeButtonPressed(_ sender: Any) {
        let composeNaviView = storyboard!.instantiateViewController(withIdentifier: Constant.StoryBoardID.composeView)
        let composeView = composeNaviView.children[0] as! EditViewController
        composeView.closureBlock =  {self.dismiss(animated: true, completion: nil)}
        self.present(composeNaviView, animated: true, completion: nil)
    }
    
}
