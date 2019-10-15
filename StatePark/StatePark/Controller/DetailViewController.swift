//
//  DetailViewController.swift
//  StatePark
//
//  Created by Jiaxing Han on 10/9/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var parkImageView: UIImageView!
    
    var captionLabelText: String?
    var parkImageName: String?
    var parksModel = ParkImageModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Default: display the first park
        if (parkImageName == nil) {
            parkImageName = parksModel.getImageNameOfParkAt(index: 0)[0]
            captionLabelText = parksModel.getCaptionsOfParkAt(index: 0)[0]
        }
        
        // Set detail view
        let image = UIImage(named: parkImageName!)
        let scale = scaleFor(size: image!.size)
        parkImageView.image = image
        parkImageView.frame.size = CGSize(width: scale * image!.size.width, height: scale * image!.size.height)
        parkImageView.center = self.view.center
        captionLabel.text = captionLabelText
    
    }
    
    // Walkthrough support for iPads
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayIntro()
    }
    
    // Show walkthrough
    func displayIntro() {
        let userDefaults = UserDefaults.standard
        let displayed = userDefaults.bool(forKey: "Displayed")
        // IF USER HAVE CLICKED START BUTTON, DON'T DISPLAY
        if !displayed {
            if let pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") {
                self.present(pageViewController, animated: true, completion: nil)
            }
        }
    }
    
    // Reposition the image when orientation changed
    override func viewDidLayoutSubviews() {
        if (parkImageView.image != nil) {
            let size = parkImageView.image!.size
            let scale = scaleFor(size: size)
            parkImageView.frame.size = CGSize(width: scale * size.width, height: scale * size.height)
            parkImageView.center = self.view.center
        }
    }
    
    // MARK: Helper
    func scaleFor(size:CGSize) -> CGFloat {
        let viewSize = self.view.bounds.size
        let widthScale = viewSize.width/size.width
        let heightScale = viewSize.height/size.height
        return min(widthScale,heightScale)
    }
}

