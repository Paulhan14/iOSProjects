//
//  InfoViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/10/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class InfoViewController: UIViewController {

    // MARK: - UI
    @IBOutlet weak var firstNameField: LoginTextField!
    @IBOutlet weak var lastNameField: LoginTextField!
    @IBOutlet weak var emailField: LoginTextField!
    @IBOutlet weak var passwordField: LoginTextField!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    // MARK: variable
    var firebaseManager = FirebaseManager.shared
    var postController = PostController.postController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fieldPlaceHolderSetUp()
        setupKeyboardAccessory()
    }
    
    func fieldPlaceHolderSetUp() {
        firstNameField.placeholder = "Ex: John"
        lastNameField.placeholder = "Ex: Smith"
        emailField.placeholder = "Ex: name@company.com"
        passwordField.placeholder = "Set your password"
    }
    
    // MARK: - Buttons
    @IBAction func actionButtonPressed(_ sender: Any) {
        // Dismiss keyboard if it is still showing
        self.view.endEditing(true)
        // sign up
        createAccount()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - Online
    
    func createAccount() {
        // Validate fields
        let error = validateSignUpFields()
        if error != nil {
            errorLabel.text = error
        } else {
            // create user
            let enteredFirst = firstNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let enteredLast = lastNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let enteredEmail = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let enteredPassword = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().createUser(withEmail: enteredEmail, password: enteredPassword) { (result, error) in
                if error != nil {
                    //error
                    self.errorLabel.text = "something went wrong"
                } else {
                    let newUID = result!.user.uid
                    // Data to be inserted
                    let payload = [
                        "first" : enteredFirst,
                        "last" : enteredLast,
                        "uid" : newUID
                    ]
                    // Upload data
//                    self.saveDataToFirebase(payload, newUID)
                    self.firebaseManager.saveUserDataToFirebase(payload, newUID)
                    self.postController.deleteAllPosts()
                    // go to home screen
                    self.goToHomeScreen()
                    //Save the user info to local
                    UserController.userController.createUser(enteredFirst, enteredLast, enteredEmail, newUID)
                }
            }
        }
    }
    
    // MARK: - Helper
    
    func validateSignUpFields() -> String? {
        if firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please enter all the information"
        }
        
        let enteredEmail = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Helpers.isValidEmail(enteredEmail) == false {
            return "Please enter correct email fromat"
        }
        
        let enteredPassword = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Helpers.checkPassword(enteredPassword) == false {
            return "Password is not strong enough"
        }
        
        return nil
    }
    
    func setupKeyboardAccessory() {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.width, height: 30)))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexible, done], animated: false)
        toolbar.sizeToFit()
        firstNameField.inputAccessoryView = toolbar
        lastNameField.inputAccessoryView = toolbar
        emailField.inputAccessoryView = toolbar
        passwordField.inputAccessoryView = toolbar
    }
    
    func goToHomeScreen() {
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        let home = storyboard?.instantiateViewController(withIdentifier: Constant.StoryBoardID.appView)
        appDelegate.window?.rootViewController = home
        appDelegate.window?.makeKeyAndVisible()
        self.view.removeFromSuperview()
    }

}
