//
//  FavoriteTableViewController.swift
//  Campus Walk
//
//  Created by Jiaxing Han on 10/19/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class FavoriteTableViewController: UITableViewController {
    
    var theFavoriteModel = FavoriteModel.theFavoriteModel
    var buildingsModel = BuildingModel.sharedInstance
    var closureBlock : (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theFavoriteModel.getFavoriteListSize()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath)
        let name = theFavoriteModel.getBuildingNameAt(indexPath.row)
        cell.textLabel?.text = name
        cell.isUserInteractionEnabled = false
        return cell
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "AddFavorite":
            let listViewController = segue.destination.children[0] as! ListTableViewController
            listViewController.segueType = segue.identifier
            listViewController.closureBlock = {indexPath in
                self.addBuildingBy(indexPath)
                self.dismiss(animated: true, completion: nil)
                self.tableView.reloadData()
            }
        default:
            break
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if let _block = closureBlock {
            _block()
        }
    }
    
    // MARK: Helper
    func addBuildingBy(_ indexPath: IndexPath) {
        let key = buildingsModel.buildingKeys[indexPath.section]
        let building = buildingsModel.buildingByInitial[key]![indexPath.row]
        if theFavoriteModel.addBuildingToList(building) == false {
            let alert = UIAlertController(title: "Already in favorite list", message: "This building has already been added to the list.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true)
//            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
