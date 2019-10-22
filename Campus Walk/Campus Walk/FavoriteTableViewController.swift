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
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Favorite list has only one cell
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Get rows from the model
        return theFavoriteModel.getFavoriteListSize()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Set each cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath)
        let name = theFavoriteModel.getBuildingNameAt(indexPath.row)
        cell.textLabel?.text = name
        cell.isUserInteractionEnabled = true
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let building = theFavoriteModel.getBuildingBy(indexPath.row)
            let name = building.name
            theFavoriteModel.removeBuildingFromList(name)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "AddFavorite":
            let listViewController = segue.destination.children[0] as! ListTableViewController
            listViewController.segueType = segue.identifier
            listViewController.closureBlock = {indexPath in
                // Add building with the index path returned from the other view
                self.addBuildingBy(indexPath)
                // dismiss the other view
                self.dismiss(animated: true, completion: nil)
                // Reload the table based on new data in model
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
    
    // If user add a building to the view, add it to model
    func addBuildingBy(_ indexPath: IndexPath) {
        let key = buildingsModel.buildingKeys[indexPath.section]
        let building = buildingsModel.buildingByInitial[key]![indexPath.row]
        if theFavoriteModel.addBuildingToList(building) == false {
        }
    }
}
