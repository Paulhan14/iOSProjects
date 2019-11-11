//
//  LoginViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/9/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var SignupButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let loginPage = segue.destination as? InfoViewController {
            switch segue.identifier {
            case "SignupSegue":
                loginPage.configureWith(segue: segue.identifier!)
            case "LoginSegue":
                loginPage.configureWith(segue: segue.identifier!)
            default:
                break
            }
        }
    }
    

}
