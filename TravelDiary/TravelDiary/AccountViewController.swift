//
//  AccountViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 12/15/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var changeNameButton: UIButton!
    @IBOutlet weak var signoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func changePasswordPressed(_ sender: Any) {
        showDialog()
    }
    @IBAction func changeNamePressed(_ sender: Any) {
        let alert = UIAlertController(title: "Change name", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "First Last"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let name = alert.textFields?.first?.text {
                let names = name.split(separator: " ")
                let first = names[0]
                let last = names[1]
                let user = Auth.auth().currentUser
                if let user = user {
                    let payload = [
                        "first": first.description,
                        "last": last.description,
                        "uid": user.uid,
                    ]
                    FirebaseManager.shared.saveUserDataToFirebase(payload, user.uid)
                }
            }
        }))
        
        self.present(alert, animated: true)
    }
    @IBAction func signoutPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes!", style: .destructive, handler: { action in
            try! Auth.auth().signOut()
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
            let home = self.storyboard?.instantiateViewController(withIdentifier: Constant.StoryBoardID.loginView)
            appDelegate.window?.rootViewController = home
            appDelegate.window?.makeKeyAndVisible()
            self.view.removeFromSuperview()
        }))
        self.present(alert, animated: true)
    }
    
    func showDialog() {
        let alert = UIAlertController(title: "Change password", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input your old password here..."
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let password = alert.textFields?.first?.text {
                let user = Auth.auth().currentUser
                if let user = user {
                    let credential: AuthCredential = EmailAuthProvider.credential(withEmail: user.email!, password: password)
                    
                    // Prompt the user to re-provide their sign-in credentials
                    user.reauthenticate(with: credential, completion: { (result, error) in
                        if error != nil {
                            let alert = UIAlertController(title: "Try again", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        } else {
                            self.askNewPassword()
                        }
                    })
                }
            }
        }))
        
        self.present(alert, animated: true)
    }
    
    func askNewPassword() {
        let alert = UIAlertController(title: "Change password", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input your new password here..."
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let password = alert.textFields?.first?.text {
                Auth.auth().currentUser?.updatePassword(to: password) { (error) in
                    if error != nil {
                        let alert = UIAlertController(title: "Try again", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    } else {
                        let alert = UIAlertController(title: "Password Changed", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            }
        }))
        self.present(alert, animated: true)
    }
    
}
