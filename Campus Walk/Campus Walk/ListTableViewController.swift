//
//  ListTableViewController.swift
//  Campus Walk
//
//  Created by Jiaxing Han on 10/18/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    var buildingModel = BuildingModel.sharedInstance
    var segueType: String?
    var closureBlock : ((_ indexPath: IndexPath) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return buildingModel.numberOfKeys
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildingModel.numberOfBuildingsAtSection(index: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        // Set each cell with information provided by model
        let name = buildingModel.buildingNameAt(indexPath)
        cell.textLabel?.text = name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return buildingModel.buildingKeys[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return buildingModel.buildingKeys
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // return the selected index path to caller view controller
        switch segueType! {
        case "AddFavorite":
            if let _block = closureBlock {
                _block(indexPath)
            }
        case "DropPin":
            if let _block = closureBlock {
                _block(indexPath)
            }
        default:
            break
        }
    }
}
