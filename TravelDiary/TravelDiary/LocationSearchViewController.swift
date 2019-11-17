//
//  LocationSearchViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/16/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchViewController: UIViewController, MKMapViewDelegate {
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var closureBlock : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let viewRegion = MKCoordinateRegion(center: userLocation, span: span)
            mapView.setRegion(viewRegion, animated: true)
        }
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        self.navigationItem.rightBarButtonItem = MKUserTrackingBarButtonItem(mapView: mapView)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Button Handler
    @IBAction func cancelPressed(_ sender: Any) {
        if let block = self.closureBlock {
            block()
        }
    }
}

extension LocationSearchViewController: CLLocationManagerDelegate {
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Map error\(error)")
    }
}
