//
//  ViewController.swift
//  Campus Walk
//
//  Created by Jiaxing Han on 10/17/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//  Toolbar and navigation bar icons are made by Freepik from www.flaticon.com
//  Signpost icon (app icon) made by Icons8
//

import UIKit
import MapKit

// For regular pin
class BuildingPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var buildingIndex: IndexPath?
    init(name: String, coordinate: CLLocationCoordinate2D, buildingIndex: IndexPath) {
        self.title = name
        self.coordinate = coordinate
        self.buildingIndex = buildingIndex
    }
}

// For favorite pin
class FavoritePin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var buildingIndex: Int?
    init(name: String, coordinate: CLLocationCoordinate2D, buildingIndex: Int) {
        self.title = name
        self.coordinate = coordinate
        self.buildingIndex = buildingIndex
    }
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var buildingModel = BuildingModel.sharedInstance
    var theFavoriteModel = FavoriteModel.theFavoriteModel
    var userDefined = UserDefinedPhoto.userDefined
    // All normal pin on map
    var allNormalPins = [String]()
    // All favorite pin on map
    var allFavoritePins = [FavoritePin]()
    // Current map type 0:standard 1:satellite 2:hybird
    var mapType = 0
    // Display favorite list or not
    var showFavoriteOrNot = true
    let spanDelta = 0.01
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Center map to Pattee Library
        let library = buildingModel.getBuildingBy(index: 36)
        let initialCoordinate = CLLocationCoordinate2D(latitude: library.latitude, longitude: library.longitude)
        let span = MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        let region = MKCoordinateRegion(center: initialCoordinate, span: span)
        mapView.region = region
        mapView.delegate = self
        mapView.showsUserLocation = true
        // Display Penn State logo
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
                self.navigationItem.leftBarButtonItem = MKUserTrackingBarButtonItem(mapView: mapView)
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
            self.navigationItem.leftBarButtonItem = MKUserTrackingBarButtonItem(mapView: mapView)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        // If user want to drop one pin
        case "DropPin":
            let listViewController = segue.destination.children[0] as! ListTableViewController
            listViewController.segueType = segue.identifier
            listViewController.closureBlock = {indexPath in
                self.dismiss(animated: true, completion: nil)
                self.dropPinForBuildingAt(indexPath)
            }
        // If user want to open favorite menu
        case "OpenFavorite":
            let favoriteViewController = segue.destination.children[0] as! FavoriteTableViewController
            favoriteViewController.closureBlock = {
                self.dismiss(animated: true, completion: nil)
                //display all the favorite buildings
                self.dropPinForFavoriteBuildings()
            }
        // If user is going to open settings
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
        case "GetDirection":
            let directionViewController = segue.destination.children[0] as! DirectionViewController
            directionViewController.closureBlock = {self.dismiss(animated: true, completion: nil)}
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // For different category, add different pin
        switch annotation {
        case is BuildingPin:
            let pin = annotation as! BuildingPin
            let view = annotationView(forPin: pin)
            var imageName = ""
            let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
            leftIconView.contentMode = .scaleToFill
            
            if buildingModel.checkPhotoAt(pin.buildingIndex!) {
                imageName = buildingModel.photoNameAt(pin.buildingIndex!)
            } else {
                imageName = "nophoto"
            }
            if let userImage = userDefined.getPhotoAt(indexPath: pin.buildingIndex!) {
                leftIconView.image = userImage
                view.leftCalloutAccessoryView = leftIconView
            } else {
                leftIconView.image = UIImage(named: imageName)
                view.leftCalloutAccessoryView = leftIconView
            }
            return view
        case is FavoritePin:
            let pin = annotation as! FavoritePin
            let view = annotationView(forPin: pin)
            var imageName = ""
            let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
            leftIconView.contentMode = .scaleToFill
            
            let building = theFavoriteModel.getBuildingBy(pin.buildingIndex!)
            
            if building.photo != "" {
                imageName = building.photo
            } else {
                imageName = "nophoto"
            }
            
            let indexPath = theFavoriteModel.indexPaths[building.name]
            if let userImage = userDefined.getPhotoAt(indexPath: indexPath!) {
                leftIconView.image = userImage
                view.leftCalloutAccessoryView = leftIconView
            } else {
                leftIconView.image = UIImage(named: imageName)
                view.leftCalloutAccessoryView = leftIconView
            }
            
            return view
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
        pin.canShowCallout = true
        return pin
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        switch view.annotation {
        // If it is a normal pin, configure callout
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
            
            if let presenter = alertController.popoverPresentationController {
                presenter.sourceView = view
                presenter.sourceRect = view.bounds
                mapView.deselectAnnotation(view.annotation, animated: true)
            }
            
            self.present(alertController, animated: true, completion: nil)
        // If it is a favorite pin, do nothing
        case is FavoritePin:
            break
        default:
            break
        }
        
    }
    
    // Drop a pin for the building
    func dropPinForBuildingAt(_ indexPath: IndexPath) {
        let building = buildingModel.buildingAt(indexPath)
        let name = building.name
        let coordinates = CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)
        
        // If it is already added, return
        guard allNormalPins.contains(name) == false else {
            centerMapCameraAt(coordinates)
            return}
        
        // If the favorite pins are displayed and it is in there, return
        if theFavoriteModel.checkTheBuildingWith(name: name) && self.showFavoriteOrNot {
            centerMapCameraAt(coordinates)
            return
        }
        // Drop pin, update the all pin list and center camera
        allNormalPins.append(name)
        let pin = BuildingPin(name: name, coordinate: coordinates, buildingIndex: indexPath)
        mapView.addAnnotation(pin)
        centerMapCameraAt(coordinates)
    }
    
    // Drop all the favorite pin
    func dropPinForFavoriteBuildings() {
        mapView.removeAnnotations(allFavoritePins)
        allFavoritePins = [FavoritePin]()
        guard theFavoriteModel.getFavoriteListSize() > 0 else {return}
        var _favoritePins = [FavoritePin]()
        for index in 0..<theFavoriteModel.getFavoriteListSize() {
            let building = theFavoriteModel.getBuildingBy(index)
            let name = building.name
            let coordinates = CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)
            let pin = FavoritePin(name: name, coordinate: coordinates, buildingIndex: index)
            _favoritePins.append(pin)
        }
        allFavoritePins = _favoritePins
        if self.showFavoriteOrNot {
            mapView.addAnnotations(_favoritePins)
        }
    }
    
    // MARK: Helper
    
    // center camera at a position
    func centerMapCameraAt(_ coordinates: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 1.0) {
            self.mapView.camera = MKMapCamera(lookingAtCenter: coordinates, fromDistance: 2000, pitch: 0, heading: 0)
        }
    }
    
    // Remove a building from the all pin list
    func removeFromAllPins(_ name: String) {
        let index = allNormalPins.firstIndex(of: name)
        if index != nil {
            allNormalPins.remove(at: index!)
        }
    }
    
    // Set the map type based on user's request
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
    
    // Show or hide favorite pins based on user's request
    func toggleFavoritePins(_ isON: Bool) {
        if isON {
            self.mapView.addAnnotations(self.allFavoritePins)
        } else {
            self.mapView.removeAnnotations(self.allFavoritePins)
        }
    }
}

