//
//  MapViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/9/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import MapKit

class PostAnnotation : MKPointAnnotation {
    var post: Post
    init(post: Post) {
        self.post = post
    }
}

class MapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    let postController = PostController.postController

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        dropPostPins()
        self.navigationItem.title = "Location Search"
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            mapFocusOn(userLocation)
        }
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        mapView.showsUserLocation = true
    }
    
    func dropPostPins(){
        var postCoordinate = CLLocationCoordinate2D()
        for post in postController.posts {
            guard post.latitude != 0, post.longitude != 0 else {continue}
            postCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(floatLiteral: post.latitude), longitude: CLLocationDegrees(floatLiteral: post.longitude))
            let annotation = PostAnnotation(post: post)
            annotation.coordinate = postCoordinate
            annotation.title = post.location
            mapView.addAnnotation(annotation)
        }
        mapFocusOn(postCoordinate)
    }
    
    func mapFocusOn(_ location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "MapPostPin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = PostAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        } else {
            pinView?.annotation = annotation
        }
//        pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//        pinView?.canShowCallout = true
        return pinView
    }
}

extension MapViewController: CLLocationManagerDelegate {
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
            mapFocusOn(location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Map error\(error)")
    }
}
