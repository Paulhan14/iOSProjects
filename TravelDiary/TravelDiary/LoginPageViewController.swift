//
//  LoginPageViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/21/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class LoginPageViewController: UIViewController {
    // MARK: Views
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet weak var errorLabel: UILabel!
    // MARK: variable
    var firebaseManager = FirebaseManager.shared
    var userController = UserController.userController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fieldPlaceHolderSetUp()
        setupKeyboardAccessory()
    }
    
    func fieldPlaceHolderSetUp() {
        emailField.placeholder = "Ex: name@company.com"
        passwordField.placeholder = "Enter your password"
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        // Dismiss keyboard if it is still showing
        self.view.endEditing(true)
        loginUser()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: Helper
    
    func loginUser() {
        let error = validateLoginFields()
        if error != nil {
            errorLabel.text = error
        } else {
            // log in
            let enteredEmail = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let enteredPassword = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().signIn(withEmail: enteredEmail, password: enteredPassword) { (result, error) in
                if error != nil {
                    self.errorLabel.text = error!.localizedDescription
                } else {
                    let newUID = result!.user.uid
                    self.firebaseManager.getUserDataFromFirebase(newUID, completion: { (data) in
                        if let first = data["first"], let last = data["last"] {
                            let loginUser = self.userController.getUser(by: newUID)
                            if loginUser == nil {
                                self.userController.createUser(first, last, enteredEmail, newUID)
                                // go to home screen
                                PostController.postController.getPostForCurrentUser(newUID)
                                PostController.postController.getFeedPosts()
                                self.goToHomeScreen()
                                
                                
                            } else {
                                self.userController.loginUser = loginUser
                                // go to home screen
                                PostController.postController.getPostForCurrentUser(newUID)
                                PostController.postController.getFeedPosts()
                                self.goToHomeScreen()
                                
                            }
                        }
                    })
                }
            }
        }
    }
    
    func validateLoginFields() -> String? {
        if emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please enter all the information"
        }
        
        let enteredEmail = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Helpers.isValidEmail(enteredEmail) == false {
            return "Please enter correct email fromat"
        }
        
        return nil
    }
    
    func setupKeyboardAccessory() {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.width, height: 30)))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexible, done], animated: false)
        toolbar.sizeToFit()
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
