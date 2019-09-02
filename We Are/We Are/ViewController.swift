//
//  ViewController.swift
//  We Are
//
//  Created by Jiaxing Han on 8/29/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var weAreLabel: UILabel!
    
    @IBOutlet weak var pennStateLabel: UILabel!
    
    var cheerCount = 0
    
    var isEvenCheerCount : Bool {return cheerCount%2 == 0}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pennStateLabel.isHidden = true
    }

    @IBAction func cheerPressed(_ sender: Any) {
        
        weAreLabel.isHidden = !isEvenCheerCount
        pennStateLabel.isHidden = isEvenCheerCount
        
        cheerCount += 1
    }
    
}

