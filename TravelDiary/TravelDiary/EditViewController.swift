//
//  EditViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/9/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import MapKit
import HealthKit
import CoreLocation
import CoreData

class EditViewController: UIViewController {

    // MARK: - UI Components
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    // MARK: - Tool Bar
    var controlToolBar: UIToolbar?
    var controlTooBarContainer: UIView?
    // MARK: - Info Views
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var stepImage: UIImageView!
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imagesViewHeightConstraint: NSLayoutConstraint!
    // MARK: - Support Views
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imagesContainerView: UIView!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    var closureBlock : (() -> Void)?
    var editingPost = postParameters()
    var draft = PostController.postController.draft
    
    var placeSelected: MKPlacemark?
    let healthStore = HKHealthStore()
    var stepCountInfo = String()
    
    let picker = UIImagePickerController()
    let imageManager = ImageManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        loadSetup()
        setupKeyboardAccessory()
        textField.inputAccessoryView = controlToolBar
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    @IBAction func cancelButtonPressed(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let discard = UIAlertAction(title: "Discard", style: .destructive) { (action) in
            // Delete the draft
            PostController.postController.deleteDraft()
            // dismiss the view
            if let block = self.closureBlock {
                block()
            }
        }
        let save = UIAlertAction(title: "Save Draft", style: .default) { (action) in
            // Create a new draftMO using the editing post
            self.prepareForClosing()
            PostController.postController.createDraft(self.editingPost)
            // Dismiss the view
            if let block = self.closureBlock {
                block()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(save)
        actionSheet.addAction(discard)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        // Create a new MO using the editing post
        self.prepareForClosing()
        PostController.postController.createPost(self.editingPost)
        PostController.postController.deleteDraft()
        // Dismiss the view
        if let block = closureBlock {
            block()
        }
    }
    
    @objc func dismissKeyboard() {
        textField.endEditing(true)
    }
    
    @objc func openLocationSearch() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchNavi = storyboard.instantiateViewController(
            withIdentifier: Constant.StoryBoardID.locationSearchView)
        let searchView = searchNavi.children.first! as! LocationSearchViewController
        searchView.closureBlock = { location in
            self.dismiss(animated: true, completion: nil)
            if location != nil {
                self.placeSelected = location
                self.locationLabel.text = location!.name
                self.dropPinFor(location!)
                self.locationLabel.isHidden = false
                if self.mapViewHeightConstraint.constant == 0.0 {
                    self.mapViewHeightConstraint.constant = 180.0
                    self.editView.layoutIfNeeded()
                }
            }
        }
        searchNavi.modalPresentationStyle = .overFullScreen
        self.present(searchNavi, animated: true) {}
    }
    
    @objc func addSteps() {
        if HKHealthStore.isHealthDataAvailable() {
            let status = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .stepCount)!)
            switch status {
            case .sharingAuthorized:
                let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
                let now = Date()
                let startOfDay = Calendar.current.startOfDay(for: now)
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
                let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
                    guard let result = result else {
                        print("\(String(describing: error?.localizedDescription)) ")
                        return
                    }
                    if let count = result.sumQuantity() {
                        let value = count.doubleValue(for: .count())
                        self.stepCountInfo = String(Int(value))
                    }
                }
                self.healthStore.execute(query)
                self.stepLabel.text = self.stepCountInfo
            case .notDetermined:
                self.setupHealhKitData()
            case .sharingDenied:
                break
            default:
                break
            }
        }
    }
    
    @objc func addImage() {
        let alertController = UIAlertController(title: "Add a photo", message: "", preferredStyle: .actionSheet)
        let actionSelect = UIAlertAction(title: "Select Form Library", style: .default) { (action) in
            let imagePicker = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                imagePicker.delegate = self
                imagePicker.sourceType = .savedPhotosAlbum
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        alertController.addAction(actionSelect)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(actionCancel)
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    // pick weather
    @objc func chooseWeather() {
        let alertController = UIAlertController(title: "Choose a weather", message: "How would you describe today?", preferredStyle: .actionSheet)
        let sunny = UIAlertAction(title: "Sunny", style: .default) { (action) in
            self.setWeatherImage("sunny")
        }
        alertController.addAction(sunny)
        let rainy = UIAlertAction(title: "Rainy", style: .default) { (action) in
            self.setWeatherImage("rainy")
        }
        alertController.addAction(rainy)
        let snowy = UIAlertAction(title: "Snowy", style: .default) { (action) in
            self.setWeatherImage("snowy")
        }
        alertController.addAction(snowy)
        let windy = UIAlertAction(title: "Windy", style: .default) { (action) in
            self.setWeatherImage("windy")
        }
        alertController.addAction(windy)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(actionCancel)
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Helper
    func loadSetup() {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        self.timeLabel.text = format.string(from: date)
        if draft != nil {
            if draft!.text == "Write something about your day..." {
                self.textField.textColor = .gray
            }
            textField.text = draft!.text
            locationLabel.text = draft!.location
            if draft!.longitude != 0, draft!.latitude != 0 {
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(floatLiteral: draft!.latitude), longitude: CLLocationDegrees(floatLiteral: draft!.longitude))
                self.placeSelected = MKPlacemark(coordinate: coordinate)
                self.dropPinFor(self.placeSelected!)
            } else {
                self.mapViewHeightConstraint.constant = 0.0
            }
            if draft!.image != nil {
                let image = imageManager.convertToImage(data: draft!.image!)!
                self.selectedImageView.image = image
                self.imagesViewHeightConstraint.constant = 180.0
            } else {
                self.imagesViewHeightConstraint.constant = 0.0
            }
            self.setWeatherImage(draft!.weather ?? "")
            self.stepLabel.text = draft!.steps
        } else {
            self.textField.text = "Write something about your day..."
            self.textField.textColor = .gray
            self.locationLabel.text = ""
            self.locationLabel.isHidden = true
            self.stepLabel.text = ""
            self.mapViewHeightConstraint.constant = 0.0
            self.imagesViewHeightConstraint.constant = 0.0
            self.editView.layoutIfNeeded()
        }
        self.mapView.delegate = self
    }
    
    // Construct configuration for this post
    func prepareForClosing() {
        editingPost.text = textField.text
        // If user added a location, record the data
        if placeSelected != nil {
            editingPost.location = locationLabel.text ?? ""
            editingPost.longitude = Double(placeSelected!.coordinate.longitude)
            editingPost.latitude = Double(placeSelected!.coordinate.latitude)
        }
        if selectedImageView.image != nil {
            editingPost.image = imageManager.convertToData(image: selectedImageView.image!)!
        }
        editingPost.steps = stepLabel.text ?? ""
        editingPost.time = Date()
        editingPost.weather = weatherLabel.text ?? ""
    }
    
    func setupKeyboardAccessory() {
        controlToolBar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.width, height: 50)))
        var flexibles = [UIBarButtonItem]()
        for _ in 0..<6{
            let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            flexibles.append(flexible)
        }
        let place = UIBarButtonItem(title: "Place", style: .plain, target: self, action: #selector(openLocationSearch))
        let photo = UIBarButtonItem(title: "Photo", style: .plain, target: self, action: #selector(addImage))
        let weather = UIBarButtonItem(title: "Weather", style: .plain, target: self, action: #selector(chooseWeather))
        let steps = UIBarButtonItem(title: "Steps", style: .plain, target: self, action: #selector(addSteps))
        let key = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        controlToolBar!.setItems([flexibles[0], place, flexibles[1], photo, flexibles[2], weather, flexibles[3], steps, flexibles[4], key, flexibles[5]], animated: false)
        controlToolBar!.sizeToFit()
        controlToolBar!.backgroundColor = .orange
    }
    
    override var canBecomeFirstResponder: Bool { get { return true } }
    override var inputAccessoryView: UIView? {
        get {
            if self.controlTooBarContainer == nil {
                let barFrame = self.controlToolBar!.frame
                let frame = CGRect(origin: CGPoint(x: barFrame.minX, y: barFrame.minY), size: CGSize(width: barFrame.width, height: barFrame.height + self.view.safeAreaInsets.bottom))
                self.controlTooBarContainer = UIView(frame: frame)
            }
            if self.controlToolBar!.superview != self.controlTooBarContainer {
                self.controlToolBar!.translatesAutoresizingMaskIntoConstraints = true
                self.controlTooBarContainer!.addSubview(self.controlToolBar!)
            }
            return self.controlTooBarContainer
        }
    }
    
    func setupHealhKitData() {
        if HKHealthStore.isHealthDataAvailable() {
            let stepCount = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])
            healthStore.requestAuthorization(toShare: stepCount, read: stepCount) { (success, error) in
                if !success {
                    print("Error reading health data: \(String(describing: error))")
                    return
                }
            }
        }
    }
    
    func setWeatherImage(_ weather: String) {
        guard weather != "" else {return}
        self.weatherImage.image = UIImage(named: weather)
        self.weatherLabel.text = weather
    }
}

extension EditViewController {
    //Mark: - Notification Handlers
    @objc func keyboardWillShow(notification:Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        // Handle scroll
        let contentInsets =  UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + controlToolBar!.bounds.height, right: 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        let selectedRange = self.textField.selectedRange
        self.textField.scrollRangeToVisible(selectedRange)
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        
    }
}

extension EditViewController: MKMapViewDelegate {
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
        guard self.placeSelected != nil else { return }
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

extension EditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imagesViewHeightConstraint.constant = 180.0
            self.selectedImageView.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
}
