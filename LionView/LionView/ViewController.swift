//
//  ViewController.swift
//  LionView
//
//  Created by Jiaxing Han on 9/9/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private let myView = UIView()
    private let myPic = UIImage()
    private let myImage = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        myView.frame = CGRect(x: 50, y: 50, width: 100, height: 100)
        myView.backgroundColor = UIColor.blue
        
        
        self.view.addSubview(myView)
    }


}

