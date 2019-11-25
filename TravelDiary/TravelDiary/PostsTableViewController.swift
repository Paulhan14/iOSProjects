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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func configureCell(_ cell: UITableViewCell, withObject object: NSManagedObject) {
        let post = object as! Post
        let myPostCell = cell as! MyPostViewCell
        myPostCell.postField.text = post.text
//        if post.image != nil {
//            let image = ImageManager.shared.convertToImage(data: post.image!)
//            myPostCell.myImageView.image = image
//        }
        if let imageData = post.image {
            if imageData.description == "0 bytes" {
                myPostCell.imageWidth.constant = 0
            } else {
                myPostCell.imageWidth.constant = 134
                myPostCell.myImageView.image = ImageManager.shared.convertToImage(data: imageData)
            }
            
        }
        
        if let weather = post.weather {
            var weatherImage = UIImage()
            switch weather {
            case "sunny":
                weatherImage = UIImage(named: "sunny")!
            case "rainy":
                weatherImage = UIImage(named: "rainy")!
            case "windy":
                weatherImage = UIImage(named: "windy")!
            case "snowy":
                weatherImage = UIImage(named: "snowy")!
            default:
                print("no such weather")
            }
            myPostCell.weatherImage.image = weatherImage
            myPostCell.weatherLabel.text = weather
        }
        
        if let stepCount = post.steps {
            myPostCell.stepLabel.text = stepCount
        }
        
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
    
    // MARK: - Buttons
    
    @IBAction func composeButtonPressed(_ sender: Any) {
        let composeNaviView = storyboard!.instantiateViewController(withIdentifier: Constant.StoryBoardID.composeView)
        let composeView = composeNaviView.children[0] as! EditViewController
        composeView.closureBlock =  {self.dismiss(animated: true, completion: nil)}
        self.present(composeNaviView, animated: true, completion: nil)
    }
    
}
