//
//  DetailViewController.swift
//  Campus Walk
//
//  Created by Jiaxing Han on 10/24/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var buildingImage: UIImageView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descriptionText: UITextView!
    
    var indexPath: IndexPath?
    var closureBlock : ((_ indexPath: IndexPath) -> Void)?
    let buildingsModel = BuildingModel.sharedInstance
    let userDefined = UserDefinedPhoto.userDefined
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = buildingsModel.buildingNameAt(indexPath!)
        let year = buildingsModel.yearBuiltAt(indexPath!)
        if year == 0 {
            yearLabel.text = "-"
        } else {
            yearLabel.text = String(year)
        }
        var imageName = ""
        if buildingsModel.checkPhotoAt(indexPath!) {
            imageName = buildingsModel.photoNameAt(indexPath!)
        } else {
            imageName = "nophoto"
        }
        if let userImage = userDefined.getPhotoAt(indexPath: self.indexPath!) {
            buildingImage.image = userImage
        } else {
            let image = UIImage(named: imageName)
            buildingImage.image = image
        }
        buildingImage.contentMode = .scaleAspectFit
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pin", style: .plain, target: self, action: #selector(pinPressed))
        self.navigationController?.isToolbarHidden = false
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        items.append(UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed)))
        self.toolbarItems = items
        
        self.descriptionText.delegate = self
        let description = buildingsModel.getBuildingDescription(indexPath!)
        if description == "" {
            self.descriptionText.text = "Write something about this building..."
            self.descriptionText.textColor = UIColor.lightGray
        } else {
            self.descriptionText.text = description
        }
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(dismissTap)
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    // MARK: - Button Handler
    
    @objc func pinPressed() {
        if let _block = closureBlock {
            _block(indexPath!)
        }
    }
    
    @objc func editPressed() {
        let alertController = UIAlertController(title: "Change Photo", message: "", preferredStyle: .actionSheet)
        let actionTake = UIAlertAction(title: "Take a Photo", style: .default) { (action) in
            let imagePicker = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        alertController.addAction(actionTake)
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            buildingImage.image = image
            userDefined.addOrChangePhoto(indexPath: self.indexPath!, image: image)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        descriptionText.endEditing(true)
    }

}

// MARK: - TextView Delegate Methods

extension DetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionText.textColor == UIColor.lightGray {
            descriptionText.text = ""
            descriptionText.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionText.text == "" {
            descriptionText.text = "Write something about this building..."
            descriptionText.textColor = UIColor.lightGray
        }
        
        if descriptionText.text != "Write something about this building..." {
            buildingsModel.setBuildingDescription(indexPath!, descriptionText.text)
        }
    }
}

extension DetailViewController {
    //Mark: - Notification Handlers
    @objc func keyboardWillShow(notification:Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        let contentInsets =  UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        let selectedRange = self.descriptionText.selectedRange
        self.descriptionText.scrollRangeToVisible(selectedRange)
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}
