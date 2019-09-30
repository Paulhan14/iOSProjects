//
//  ParkScrollView.swift
//  StatePark
//
//  Created by Jiaxing Han on 9/26/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//  National Park https://icons8.com/icons/set/national-park icon by Icons8 https://icons8.com
//

import Foundation

import UIKit

class ParkScrollView: UIScrollView {
    private var parkImages: [UIImageView] = []
    private let parkName: String
    let parkLabel: UILabel
    var currentImageIndex: Int {return Int(self.contentOffset.y / self.bounds.height) - 1}
    
    init(parkName: String, frame: CGRect) {
        self.parkName = parkName
        self.parkLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 300, height: 50)))
        self.parkLabel.text = parkName
        self.parkLabel.font = UIFont.boldSystemFont(ofSize: 30)
        self.parkLabel.textColor = UIColor(red: 188/255, green: 143/255, blue: 143/255, alpha: 1)
        self.parkLabel.textAlignment = .center
        
        let labelCenter = CGPoint(x: frame.width/2.0, y: frame.height/2.0)
        
        super.init(frame: frame)
        self.addSubview(parkLabel)
        self.parkLabel.center = labelCenter
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initParkImages(imageNames: [String], imageCount: Int) {
        for i in 0..<imageCount {
            let aImage = UIImage(named: imageNames[i])
            let aImageView = UIImageView(image: aImage)
            self.parkImages.append(aImageView)
        }
    }
    
    func getImages() -> [UIImageView] {
        return self.parkImages
    }
    
    func isAllowedOrNot() -> Bool {
        if currentImageIndex == -1 {
            return true
        } else {
            return false
        }
    }
    
    func getParkName() -> String {
        return self.parkName
    }
    
    func getImageCount() -> Int {
        return self.parkImages.count
    }
    
}
