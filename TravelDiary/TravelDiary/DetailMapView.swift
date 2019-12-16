//
//  DetailMapView.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 12/15/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import UIKit

protocol DetailMapViewDelegate: class {
    func detailsRequestedForPost(post : Post)
}

class DetailMapView: UIView {
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    
    var post: Post?
    weak var delegate: DetailMapViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureWith(post: Post) {
        self.post = post
        if let imageData = post.image {
            if imageData.description == "0 bytes" {
                imageWidth.constant = 0
            } else {
                imageWidth.constant = 87
                imageView.image = ImageManager.shared.convertToImage(data: imageData)
            }
        } else {
            imageWidth.constant = 0
        }
        textView.text = post.text ?? ""
    }
    
    @IBAction func detailPressed(_ sender: Any) {
        if let post = post {
            delegate?.detailsRequestedForPost(post: post)
        }
    }
    
}
