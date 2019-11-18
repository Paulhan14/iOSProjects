//
//  LocationSearchTableViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/17/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTableViewController: UITableViewController {
    
    var matchingLocations = [MKMapItem]()
    var mapView: MKMapView? = nil
    
    var handleMapSearchDelegate:HandleMapSearch? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingLocations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.CellIdentifier.locationCell, for: indexPath)
        let location = matchingLocations[indexPath.row].placemark
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = parseAddress(location)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = matchingLocations[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: location)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper
    func parseAddress(_ selectedItem:MKPlacemark) -> String {
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(format:"%@%@%@%@%@%@%@", selectedItem.subThoroughfare ?? "", firstSpace,
            selectedItem.thoroughfare ?? "", comma, selectedItem.locality ?? "", secondSpace,
            selectedItem.administrativeArea ?? "")
        return addressLine
    }

}

extension LocationSearchTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = self.mapView, let text = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            self.matchingLocations = response.mapItems
            self.tableView.reloadData()
        }
    }
}
