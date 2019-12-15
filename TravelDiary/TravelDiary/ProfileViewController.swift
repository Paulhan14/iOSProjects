//
//  ProfileViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/9/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    @IBOutlet weak var backgroundImage: DesignableImageView!
    @IBOutlet weak var profileImage: DesignableImageView!
    @IBOutlet weak var nameLabel: UILabel!
    // Settings
    @IBOutlet weak var accountButton: UIView!
    @IBOutlet weak var dataButton: UIView!
    @IBOutlet weak var settingsButton: UIView!
    @IBOutlet weak var aboutButton: UIView!
    
    
    var firebaseManager = FirebaseManager.shared
    var imageManager = ImageManager.shared
    var handle: AuthStateDidChangeListenerHandle?
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        var barImageView = self.navigationController?.navigationBar.subviews.first
//        barImageView?.alpha = 0.0
//        self.scrollBgView?.delegate = self
        let changeProfileImageGesture = UITapGestureRecognizer(target: self, action: #selector(changeProfileImage))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(changeProfileImageGesture)
        profileImage.contentMode = .scaleAspectFill
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if Auth.auth().currentUser != nil {
                let uid = user!.uid
//                _ = user!.email
                self.firebaseManager.getUserDataFromFirebase(uid, completion: { (data) in
                    if let first = data["first"], let last = data["last"] {
                        self.name = "\(first) \(last)"
                        self.configurePage()
                    }
                })
            } else {
                // No user is signed in.
                print("Attempt to load user while no one signed in")
            }
            
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func changeProfileImage() {
        let alertController = UIAlertController(title: "Add a profile image", message: "Select a photo to be your profile image", preferredStyle: .actionSheet)
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

    func configurePage() {
        guard name != nil else {return}
        nameLabel.text = name!
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            firebaseManager.downloadProfileImageOfUser(uid) { (data) in
                let image = self.imageManager.convertToImage(data: data)
                self.profileImage.image = image
            }
        }
        
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profileImage.image = image
            if let user = Auth.auth().currentUser {
                let uid = user.uid
                firebaseManager.uploadProfileImageOfUser(uid, imageManager.convertToData(image: image)!)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}
