//
//  PostViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 12/10/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var insideView: UIView!
    //Info small view
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var atLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    // Map view
    @IBOutlet weak var mapView: DesignableMapView!
    @IBOutlet weak var mapViewHeight: NSLayoutConstraint!
    // Image view
    @IBOutlet weak var imageView: DesignableImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    //Text Field
    @IBOutlet weak var textField: DesignableTextView!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    // Variables
    var closureBlock : (() -> Void)?
    var postToShow: Post?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        if postToShow != nil {
            configurePage()
        }
        self.mapView.isScrollEnabled = false
        self.textField.isEditable = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Button
    @objc func done() {
        // Dismiss the view
        if let block = closureBlock {
            block()
        }
    }
    @IBAction func sharePost(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 0.0)
        insideView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let viewHeight = self.view.frame.size.height
        let containerHeight = insideView.bounds.size.height
        let ratio = containerHeight / viewHeight
        
        if let image = screenshot {
            let cgImage = image.cgImage!
            let properSize = CGSize(width: CGFloat(integerLiteral: cgImage.width) , height: CGFloat(integerLiteral: cgImage.height) * ratio)
            let rect = CGRect(origin: .zero, size: properSize)
            
            let croppedCGImage = cgImage.cropping(to: rect)
            let result = UIImage(cgImage: croppedCGImage!)
            UIImageWriteToSavedPhotosAlbum(result, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

    // MARK: - Helper
    func configurePage() {
        textField.text = postToShow!.text
        locationLabel.text = postToShow!.location
        // Has location infos
        if postToShow!.longitude != 0, postToShow!.latitude != 0 {
            // Construct MKPlacemark
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(floatLiteral: postToShow!.latitude), longitude: CLLocationDegrees(floatLiteral: postToShow!.longitude))
            let placeSelected = MKPlacemark(coordinate: coordinate)
            // Drop a pin
            self.dropPinFor(placeSelected)
            self.mapViewHeight.constant = 180.0
        } else {
            // No location info, hide mapview
            self.mapViewHeight.constant = 0.0
        }
        
        if let imageData = postToShow!.image {
            if imageData.description == "0 bytes" {
                self.imageViewHeight.constant = 0.0
            } else {
                self.imageView.image = ImageManager.shared.convertToImage(data: imageData)
                self.imageViewHeight.constant = 180.0
            }
        } else {
            self.imageViewHeight.constant = 0.0
        }
        
        if let weather = postToShow!.weather {
            if weather != "" {
                self.weatherImage.image = UIImage(named: weather)
                self.weatherLabel.text = weather
            } else {
                self.weatherImage.image = UIImage(named: "weather")
                self.weatherLabel.text = "Weather"
            }
        }
        
        self.stepLabel.text = postToShow!.steps
    }
}
    
extension PostViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "LocationPin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.canShowCallout = false
        return pinView
    }
    
    // Map helper functions
    func mapFocusOn(_ location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    func dropPinFor(_ placemark: MKPlacemark) {
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = locationLabel.text
        if let city = placemark.locality,let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        mapFocusOn(placemark.coordinate)
    }
}

extension PostViewController {
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your post snapshot has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
