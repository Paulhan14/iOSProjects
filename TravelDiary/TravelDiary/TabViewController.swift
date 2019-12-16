//
//  TabViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/16/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 1
        let colorT = ColorTheme()
        self.tabBar.barTintColor = colorT.lapiz
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
