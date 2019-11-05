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
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if segueType == "DropPin" {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(closeSelf))
        }
        if segueType == "GetStart" || segueType == "GetEnd" {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Use Current", style: .plain, target: self, action: #selector(useCurrent))
        }
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search a building"
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.searchBar.showsScopeBar = false
        searchController.searchBar.scopeButtonTitles = ["By Name", "By Year"]
//        searchController.searchBar.showsCancelButton = true
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        }
        return buildingModel.numberOfKeys
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return buildingModel.filteredBuildings.count
        }
        return buildingModel.numberOfBuildingsAtSection(index: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        // Set each cell with information provided by model
        if isFiltering {
            let filteredData = buildingModel.filteredBuildings
            let name = filteredData[indexPath.row].name
            cell.textLabel?.text = name
        } else {
            let name = buildingModel.buildingNameAt(indexPath)
            cell.textLabel?.text = name
        }
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return nil
        }
        return buildingModel.buildingKeys[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isFiltering {
            return nil
        }
        return buildingModel.buildingKeys
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // return the selected index path to caller view controller
        var indexPathToSend = indexPath
        if isFiltering {
            let name = buildingModel.filteredBuildings[indexPath.row].name
            indexPathToSend = buildingModel.getIndexPathOfBuildingWith(name)
        }
        switch segueType! {
        case "AddFavorite":
            if let _block = closureBlock {
                _block(indexPathToSend)
            }
        case "DropPin":
            if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "ScrollDetailView") as? DetailViewController {
                detailViewController.indexPath = indexPathToSend
                detailViewController.closureBlock = self.closureBlock
                navigationController?.pushViewController(detailViewController, animated: true)
            }
        case "GetStart":
            fallthrough
        case "GetEnd":
            if let _block = closureBlock {
                _block(indexPathToSend)
            }
        default:
            break
        }
    }
    
    @objc func closeSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func useCurrent() {
        if let _block = closureBlock {
            _block(IndexPath())
        }
    }
}

// MARK: - Search Bar Methods

extension ListTableViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterBuildings(searchBar.text!, searchBar.selectedScopeButtonIndex)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        let topRow = IndexPath(row: 0, section: 0)
//        tableView.scrollToRow(at: topRow, at: .top, animated: true)
//        tableView.reloadData()
    }
    
    func filterBuildings(_ text: String, _ type: Int) {
        if type == 0 {
            buildingModel.filteredBuildings = buildingModel.filter { (building: building) -> Bool in
                return building.name.lowercased().contains(text.lowercased())
            }
        } else {
            buildingModel.filteredBuildings = buildingModel.filter { (building: building) -> Bool in
                return String(building.year_constructed).contains(text)
            }
        }
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterBuildings(searchBar.text!, selectedScope)
        switch selectedScope {
        case 0:
            searchBar.text = ""
            searchBar.keyboardType = .default
            searchBar.reloadInputViews()
        case 1:
            searchBar.text = ""
            searchBar.keyboardType = .numberPad
            searchBar.reloadInputViews()
        default:
            searchBar.keyboardType = .default
        }
    }
}
