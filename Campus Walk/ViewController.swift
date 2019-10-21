//
//  ViewController.swift
//  Campus Walk
//
//  Created by Jiaxing Han on 10/17/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import MapKit

class BuildingPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.title = name
        self.coordinate = coordinate
    }
}

class FavoritePin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.title = name
        self.coordinate = coordinate
    }
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var buildingModel = BuildingModel.sharedInstance
    var theFavoriteModel = FavoriteModel.theFavoriteModel
    var allNormalPins = [String]()
    var allFavoritePins = [FavoritePin]()
    var mapType = 0
    var showFavoriteOrNot = true
    let spanDelta = 0.01
    
     let locationManager = CLLocationManager()
    
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
        
        mapView.showsUserLocation = true
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                mapView.showsUserLocation = true
            default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted:
            mapView.showsUserLocation = false
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "DropPin":
            let listViewController = segue.destination.children[0] as! ListTableViewController
            listViewController.segueType = segue.identifier
            listViewController.closureBlock = {indexPath in
                self.dismiss(animated: true, completion: nil)
                self.dropPinForBuildingAt(indexPath)
            }
        case "OpenFavorite":
            let favoriteViewController = segue.destination.children[0] as! FavoriteTableViewController
            favoriteViewController.closureBlock = {
                self.dismiss(animated: true, completion: nil)
                //display all the favorite buildings
                self.dropPinForFavoriteBuildings()
            }
        case "ToSettings":
            let settingViewController = segue.destination as! SettingViewController
            settingViewController.configureWith(index: self.mapType, onOff: self.showFavoriteOrNot)
            settingViewController.closureBlock = { returnConfigure in
                self.dismiss(animated: true, completion: nil)
                self.setMapType(returnConfigure.mapType)
                self.mapType = returnConfigure.mapType
                self.toggleFavoritePins(returnConfigure.favoriteSwitch)
                self.showFavoriteOrNot = returnConfigure.favoriteSwitch
            }
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is BuildingPin:
            return annotationView(forPin: annotation as! BuildingPin)
        case is FavoritePin:
            return annotationView(forPin: annotation as! FavoritePin)
        default:
            return nil
        }
    }
    
    // Set view for normal pin
    func annotationView(forPin buildingPin:BuildingPin) -> MKAnnotationView {
        let pinIdentifier = "BuildingPin"
        let pin = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdentifier) as? MKMarkerAnnotationView ??  MKMarkerAnnotationView(annotation: buildingPin, reuseIdentifier: pinIdentifier)
        
        pin.animatesWhenAdded = true
        pin.canShowCallout = true
        pin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return pin
    }
    
    // Set view for favorite pin
    func annotationView(forPin favoritePin:FavoritePin) -> MKAnnotationView {
        let pinIdentifier = "FavoritePin"
        let pin = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdentifier) as? MKMarkerAnnotationView ??  MKMarkerAnnotationView(annotation: favoritePin, reuseIdentifier: pinIdentifier)
        
        pin.markerTintColor = .yellow
        pin.animatesWhenAdded = false
        pin.canShowCallout = false
        pin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return pin
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        switch view.annotation {
        case is BuildingPin:
            let buildingPin = view.annotation as! BuildingPin
            let alertController = UIAlertController(title: buildingPin.title!, message: "", preferredStyle: .actionSheet)
            let actionDelete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                self.removeFromAllPins(buildingPin.title!)
                mapView.removeAnnotation(buildingPin)
            }
            alertController.addAction(actionDelete)
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(actionCancel)
            self.present(alertController, animated: true, completion: nil)
        case is FavoritePin:
            break
        default:
            break
        }
        
    }
    
    func dropPinForBuildingAt(_ indexPath: IndexPath) {
        let building = buildingModel.buildingAt(indexPath)
        let name = building.name
        let coordinates = CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)
        
        guard allNormalPins.contains(name) == false else {
            centerMapCameraAt(coordinates)
            return}
        allNormalPins.append(name)
        let pin = BuildingPin(name: name, coordinate: coordinates)
        mapView.addAnnotation(pin)
        centerMapCameraAt(coordinates)
    }
    
    func dropPinForFavoriteBuildings() {
        guard theFavoriteModel.getFavoriteListSize() > 0 else {return}
        mapView.removeAnnotations(allFavoritePins)
        var _favoritePins = [FavoritePin]()
        for index in 0..<theFavoriteModel.getFavoriteListSize() {
            let building = theFavoriteModel.getBuildingBy(index)
            let name = building.name
            let coordinates = CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)
            let pin = FavoritePin(name: name, coordinate: coordinates)
            _favoritePins.append(pin)
        }
        allFavoritePins = _favoritePins
        if self.showFavoriteOrNot {
            mapView.addAnnotations(_favoritePins)
        }
    }
    
    // MARK: Helper
    func centerMapCameraAt(_ coordinates: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 1.0) {
            self.mapView.camera = MKMapCamera(lookingAtCenter: coordinates, fromDistance: 2000, pitch: 0, heading: 0)
        }
    }
    
    func removeFromAllPins(_ name: String) {
        let index = allNormalPins.firstIndex(of: name)
        if index != nil {
            allNormalPins.remove(at: index!)
        }
    }
    
    func setMapType(_ mapType: Int) {
        switch mapType {
        case 0:
            self.mapView.mapType = .standard
        case 1:
            self.mapView.mapType = .satellite
        case 2:
            self.mapView.mapType = .hybrid
        default:
            break
        }
    }
    
    func toggleFavoritePins(_ isON: Bool) {
        if isON {
            self.mapView.addAnnotations(self.allFavoritePins)
        } else {
            self.mapView.removeAnnotations(self.allFavoritePins)
        }
    }
}

