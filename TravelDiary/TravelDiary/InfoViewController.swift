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

class InfoViewController: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    
    var parentSegue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fieldPlaceHolderSetUp()
        switch parentSegue! {
        case Constant.Segues.signup:
            createAccount()
        case Constant.Segues.login:
            firstNameField.isHidden = true
            lastNameField.isHidden = true
            actionButton.setTitle("Log in", for: .normal)
        default:
            break
        }
    }
    
    func configureWith(segue: String) {
        self.parentSegue = segue
    }
    
    func fieldPlaceHolderSetUp() {
        firstNameField.placeholder = "Enter your first name"
        lastNameField.placeholder = "Enter your last name"
        emailField.placeholder = "Enter your email address"
        passwordField.placeholder = "Set your password"
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Buttons
    @IBAction func actionButtonPressed(_ sender: Any) {
        switch parentSegue! {
        case Constant.Segues.signup:
            createAccount()
            self.goToHomeScreen()
        case Constant.Segues.login:
            loginUser()
            self.goToHomeScreen()
        default:
            break
        }
    }
    
    // MARK: - Helper
    
    func createAccount() {
        // Validate fields
        let error = validateSignUpFields()
        if error != nil {
            // There is something wrong
        } else {
            // create user
            let enteredFirst = firstNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let enteredLast = lastNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let enteredEmail = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let enteredPassword = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().createUser(withEmail: enteredEmail, password: enteredPassword) { (result, error) in
                if error != nil {
                    //error
                } else {
                    let db = Firestore.firestore()
                    var ref: DocumentReference? = nil
                    let payload = [
                        "first" : enteredFirst,
                        "last" : enteredLast,
                        "uid" : result!.user.uid
                    ]
                    ref = db.collection("users").addDocument(data: payload, completion: { (err) in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    })
                }
            }
        }
    }
    
    func loginUser() {
        let error = validateLoginFields()
        if error != nil {
            // There is something wrong
        } else {
            // log in
            
            // go to home screen
        }
    }
    
    func validateSignUpFields() -> String? {
        if firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please enter all the information"
        }
        
        let enteredPassword = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Helpers.checkPassword(enteredPassword) == false {
            return "Password is not strong enough"
        }
        
        let enteredEmail = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Helpers.isValidEmail(enteredEmail) == false {
            return "Please enter correct email fromat"
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
    
    func goToHomeScreen() {
        let home = storyboard?.instantiateViewController(withIdentifier: Constant.StoryBoardID.postsView) as? PostsTableViewController
        view.window?.rootViewController = home
        view.window?.makeKeyAndVisible()
        
    }

}
