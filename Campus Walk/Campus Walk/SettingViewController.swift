//
//  SettingViewController.swift
//  Campus Walk
//
//  Created by Jiaxing Han on 10/20/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

struct configure {
    var favoriteSwitch: Bool
    var mapType: Int
}

class SettingViewController: UIViewController {

    @IBOutlet weak var favoriteSwitch: UISwitch!
    @IBOutlet weak var mapTypeSegment: UISegmentedControl!
    @IBOutlet weak var okButton: UIButton!
    
    var closureBlock : ((_ returnConfigure: configure) -> Void)?
    var segmentIndex = 0
    var switchStatus = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapTypeSegment.setTitle("Standard", forSegmentAt: 0)
        mapTypeSegment.setTitle("Satellite", forSegmentAt: 1)
        mapTypeSegment.setTitle("Hybird", forSegmentAt: 2)
        mapTypeSegment.selectedSegmentIndex = segmentIndex
        favoriteSwitch.isOn = switchStatus
    }
    
    func configureWith(index: Int, onOff: Bool) {
        // Set the status of views based on current setting
        self.segmentIndex = index
        self.switchStatus = onOff
    }
    
    @IBAction func okButtonPressed(_ sender: Any) {
        // Construct setting configuration payload
        let returnConfigure = configure(favoriteSwitch: favoriteSwitch.isOn, mapType: mapTypeSegment.selectedSegmentIndex)
        // Return the configuration to caller view
        if let _block = closureBlock {
            _block(returnConfigure)
        }
    }
}
