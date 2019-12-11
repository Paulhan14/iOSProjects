//
//  PostViewController.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 12/10/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {
    //Info small view
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var atLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    // Map view
    @IBOutlet weak var mapView: DesignableMapView!
    @IBOutlet weak var mapViewHeight: NSLayoutConstraint!
    // Image view
    @IBOutlet weak var imageView: DesignableImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    //Text Field
    @IBOutlet weak var textField: DesignableTextView!
    
    // Variables
    var closureBlock : (() -> Void)?
    var postToShow: Post?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if postToShow != nil {
            textField.text = postToShow!.text
        }
        // Do any additional setup after loading the view.
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
