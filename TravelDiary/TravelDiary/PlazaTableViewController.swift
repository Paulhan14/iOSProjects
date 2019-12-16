//
//  PlazaTableViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/9/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import CoreData

class PlazaTableViewController: UITableViewController, FeedDataSourceCellConfigurer {
    
    lazy var dataSource : FeedDataSource = FeedDataSource(entity: "FeedPost", sortKeys: ["time"], predicate: nil, sectionNameKeyPath: "time")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.delegate = self
        dataSource.tableView = self.tableView
        tableView.dataSource = dataSource
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshFeed), for: .valueChanged)
        let colorT = ColorTheme()
        refreshControl.tintColor = colorT.lapiz
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Getting new posts")
        self.refreshControl = refreshControl
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func configureCell(_ cell: UITableViewCell, withObject object: NSManagedObject) {
        let feedPost = object as! FeedPost
        let myPostCell = cell as! FeedPostCell
        myPostCell.postField.text = feedPost.text
        
        if let imageData = feedPost.image {
            if imageData.description != "0 bytes" {
                myPostCell.imageWidth.constant = 134
                myPostCell.postImageView.image = ImageManager.shared.convertToImage(data: imageData)
            } else {
                myPostCell.imageWidth.constant = 0
            }
        } else {
            myPostCell.imageWidth.constant = 0
        }
        
        if let weather = feedPost.weather {
            var weatherImage = UIImage()
            weatherImage = UIImage(named: weather)!
            myPostCell.weatherImage.image = weatherImage
            myPostCell.weatherLabel.text = weather
        }
        
        if let stepCount = feedPost.steps {
            myPostCell.stepLabel.text = stepCount
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postView = storyboard!.instantiateViewController(withIdentifier: Constant.StoryBoardID.postView)
        let singleView = postView.children[0] as! PostViewController
        singleView.closureBlock =  {self.dismiss(animated: true, completion: nil)}
        singleView.feedPostToShow = dataSource.objectAtIndexPath(indexPath) as? FeedPost
        singleView.segueType = "Feed"
        self.present(postView, animated: true, completion: nil)
    }
    
    @objc func refreshFeed() {
        PostController.postController.getFeedPosts()
        refreshControl?.endRefreshing()
    }
}
