//
//  DirectionViewController.swift
//  Campus Walk
//
//  Created by Jiaxing Han on 10/26/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import MapKit

class DirectionViewController: UIViewController, MKMapViewDelegate {

    // MARK: outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startPickButton: UIButton!
    @IBOutlet weak var endPickButton: UIButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var serachButton: UIButton!
    @IBOutlet weak var clearRouteButton: UIButton!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var oneStepLabel: UILabel!
    @IBOutlet weak var allStepsButton: UIButton!
    @IBOutlet weak var locationPickerView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var nextStepButton: UIButton!
    
    var buildingModel = BuildingModel.sharedInstance
    var theFavoriteModel = FavoriteModel.theFavoriteModel
    let spanDelta = 0.01
    
    var startLocation: MKMapItem?
    var endLocation: MKMapItem?
    var allSteps = [MKRoute.Step]()
    var currentStep = 1
    
    var closureBlock : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let library = buildingModel.getBuildingBy(index: 36)
        let initialCoordinate = CLLocationCoordinate2D(latitude: library.latitude, longitude: library.longitude)
        let span = MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        let region = MKCoordinateRegion(center: initialCoordinate, span: span)
        mapView.region = region
        mapView.delegate = self
        mapView.showsUserLocation = true
        self.navigationItem.title = "Direction"
        locationPickerView.layer.cornerRadius = 5.0
        locationPickerView.layer.shadowColor = UIColor.black.cgColor
        locationPickerView.layer.shadowOffset = .zero
        locationPickerView.layer.shadowRadius = 5
        locationPickerView.layer.shadowOpacity = 0.3
        infoView.layer.cornerRadius = 5.0
        infoView.layer.shadowColor = UIColor.black.cgColor
        infoView.layer.shadowOffset = .zero
        infoView.layer.shadowRadius = 5
        infoView.layer.shadowOpacity = 0.3
        infoView.isHidden = true
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay{
        case is MKPolyline:
            let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5.0
            return polylineRenderer
        default:
            assert(false, "Unhandled Overlay")
        }
    }
    
    // MARK: button handler
    
    @IBAction func backPressed(_ sender: Any) {
        if let _block = closureBlock {
            _block()
        }
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        guard startLocation != nil && endLocation != nil else {return}
        
        let request = MKDirections.Request()
        request.source = startLocation
        request.destination = endLocation
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard (error == nil) else {print(error!.localizedDescription); return}
            
            if let route = response?.routes.first {
                self.mapView.addOverlay(route.polyline)
                let rect = MKCoordinateRegion(route.polyline.boundingMapRect)
                self.mapView.setRegion(rect, animated: true)
                self.mapView.camera = MKMapCamera(lookingAtCenter: rect.center, fromDistance: self.mapView.camera.altitude, pitch: 0, heading: 0)
                self.etaLabel.text = self.timeToString(seconds: route.expectedTravelTime)
                self.allSteps = route.steps
                self.oneStepLabel.text = self.allSteps[self.currentStep].instructions
                self.infoView.isHidden = false
            }
        }
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        startPickButton.setTitle("Pick Start Location", for: .normal)
        endPickButton.setTitle("Pick Destination", for: .normal)
        self.mapView.removeOverlays(self.mapView.overlays)
        infoView.isHidden = true
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        guard currentStep < allSteps.count - 1 else {return}
        currentStep += 1
        self.oneStepLabel.text = self.allSteps[self.currentStep].instructions
    }
    
    @IBAction func displayAllSteps(_ sender: Any) {
        if let stepViewController = storyboard?.instantiateViewController(withIdentifier: "StepList") as? StepTableViewController {
            stepViewController.steps = allSteps
            navigationController?.pushViewController(stepViewController, animated: true)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "GetStart":
            let listViewController = segue.destination.children[0] as! ListTableViewController
            listViewController.segueType = segue.identifier
            listViewController.closureBlock = {indexPath in
                if indexPath.isEmpty {
                    self.useCurrent(startOrEnd: true)
                } else {
                    self.setStartLocation(indexPath)
                }
                self.dismiss(animated: true, completion: nil)
            }
        case "GetEnd":
            let listViewController = segue.destination.children[0] as! ListTableViewController
            listViewController.segueType = segue.identifier
            listViewController.closureBlock = {indexPath in
                if indexPath.isEmpty {
                    self.useCurrent(startOrEnd: false)
                } else {
                    self.setEndLocation(indexPath)
                }
                self.dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
   
    // MARK: Helper
    
    func setStartLocation(_ indexPath: IndexPath) {
        let building = buildingModel.buildingAt(indexPath)
        startPickButton.setTitle(building.name, for: .normal)
        let place = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude))
        self.startLocation = MKMapItem(placemark: place)
        self.mapView.removeOverlays(self.mapView.overlays)
    }
    
    func setEndLocation(_ indexPath: IndexPath) {
        let building = buildingModel.buildingAt(indexPath)
        endPickButton.setTitle(building.name, for: .normal)
        let place = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude))
        self.endLocation = MKMapItem(placemark: place)
        self.mapView.removeOverlays(self.mapView.overlays)
    }
    
    func useCurrent(startOrEnd: Bool) {
        if startOrEnd {
            startPickButton.setTitle("Current Location", for: .normal)
            self.startLocation = MKMapItem.forCurrentLocation()
        } else {
            endPickButton.setTitle("Current Location", for: .normal)
            self.endLocation = MKMapItem.forCurrentLocation()
        }
    }
    
    func timeToString(seconds: Double) -> String{
        let min = Int(seconds) / 60
        return String(min) + " mins"
    }
}
