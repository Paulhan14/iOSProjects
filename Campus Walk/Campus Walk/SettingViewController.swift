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
        self.segmentIndex = index
        self.switchStatus = onOff
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func okButtonPressed(_ sender: Any) {
        let returnConfigure = configure(favoriteSwitch: favoriteSwitch.isOn, mapType: mapTypeSegment.selectedSegmentIndex)
        if let _block = closureBlock {
            _block(returnConfigure)
        }
    }
}
