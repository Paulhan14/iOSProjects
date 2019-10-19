//
//  ViewController.swift
//  Campus Walk
//
//  Created by Jiaxing Han on 10/17/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    var buildingModel = BuildingModel.sharedInstance
    var pinBuildingIndex: IndexPath?
    let spanDelta = 0.01
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let library = buildingModel.getBuildingBy(index: 36)
        let initialCoordinate = CLLocationCoordinate2D(latitude: library.latitude, longitude: library.longitude)
        let span = MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        let region = MKCoordinateRegion(center: initialCoordinate, span: span)
        mapView.region = region
        mapView.delegate = self
        
        self.navigationItem.leftBarButtonItem = MKUserTrackingBarButtonItem(mapView: mapView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "DropPin":
            let listViewController = segue.destination.children[0] as! ListTableViewController
            listViewController.segueType = segue.identifier
            listViewController.closureBlock = {indexPath in
                self.pinBuildingIndex = indexPath
                self.dismiss(animated: true, completion: nil)
            }
        case "OpenFavorite":
            let favoriteViewController = segue.destination.children[0] as! FavoriteTableViewController
            favoriteViewController.closureBlock = {self.dismiss(animated: true, completion: nil)}
        default:
            break
        }
    }
}

