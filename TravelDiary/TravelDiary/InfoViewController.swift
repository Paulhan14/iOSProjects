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
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    // MARK: variable
    var parentSegue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fieldPlaceHolderSetUp()
        setupKeyboardAccessory()
        switch parentSegue! {
        case Constant.Segues.login:
            firstNameField.isHidden = true
            lastNameField.isHidden = true
            actionButton.setTitle("Log in", for: .normal)
            passwordField.placeholder = "Enter your password"
        default:
            break
        }
    }
    
    func configureWith(segue: String) {
        self.parentSegue = segue
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
        // log in or sign up
        switch parentSegue! {
        case Constant.Segues.signup:
            createAccount()
        case Constant.Segues.login:
            loginUser()
        default:
            break
        }
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
                    self.saveDataToFirebase(payload, newUID)
                    // go to home screen
                    self.goToHomeScreen()
                    //Save the user info to local
                    UserController.theUser.createUser(enteredFirst, enteredLast, enteredEmail, newUID)
                }
            }
            
        }
    }
    
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
                    let data = self.getDataFromFirebase(newUID)
                    if let first = data["firstName"], let last = data["lastName"] {
                        UserController.theUser.createUser(first, last, enteredEmail, newUID)
                    }
                    // go to home screen
                    self.goToHomeScreen()
                }
            }
        }
    }
    
    func saveDataToFirebase(_ payload: [String:String], _ uid: String) {
        // Upload data
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        // Create a new document for the user
        ref = db.collection("users").document(uid)
        ref!.setData(payload, completion: { (error) in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        })
    }
    
    func getDataFromFirebase(_ uid: String) -> [String:String] {
        var data = [String:String]()
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                data = document.data() as! [String:String]
            } else {
                print("Document does not exist")
            }
        }
        return data
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
