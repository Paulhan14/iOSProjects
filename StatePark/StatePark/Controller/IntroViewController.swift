//
//  IntroViewController.swift
//  StatePark
//
//  Created by Jiaxing Han on 10/13/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var index: Int = 0
    var descriptionForPage: String?
    var imageName: String?
    var introModel = IntroModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure page components based on the page index
        pageControl.currentPage = index
        finishButton.isHidden = true
        let image = UIImage(named: imageName!)
        mainImageView!.image = image
        descriptionText.text = descriptionForPage
        
        if index == introModel.pageNum - 1 {
            nextButton.isHidden = true
            finishButton.isHidden = false
            finishButton.layer.cornerRadius = 5.0
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    // Set page details
    func configureWith(_ index: Int, _ des: String, _ imageName: String) {
        self.index = index
        self.descriptionForPage = des
        self.imageName = imageName
    }
    
    // NEXT button reaction
    @IBAction func nextButtonClicked(_ sender: Any) {
        let pageViewController = self.parent as! PageViewController
        pageViewController.nextPagePresent(index+1)
    }
    // dismiss the walkthrough
    @IBAction func finishButtonClicked(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "Displayed")
        let pageViewController = self.parent as! PageViewController
        pageViewController.dismiss(animated: true, completion: nil)
    }
}
