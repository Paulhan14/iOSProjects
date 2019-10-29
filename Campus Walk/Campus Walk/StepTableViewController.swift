//
//  StepTableViewController.swift
//  Campus Walk
//
//  Created by Jiaxing Han on 10/28/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import MapKit

class StepTableViewController: UITableViewController {
    
    var steps: [MKRoute.Step]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return steps?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EachStep", for: indexPath)
        if (indexPath.row == 0) {
            cell.textLabel?.text = "Start at selected location"
        } else {
            cell.textLabel?.text = steps?[indexPath.row].instructions
        }
        return cell
    }
}
