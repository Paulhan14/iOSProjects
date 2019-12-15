//
//  ImageManager.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/19/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ImageManager {
    static let shared = ImageManager()
    
    func convertToData(image: UIImage) -> Data? {
        return image.jpegData(compressionQuality: 0.3)
    }
    
    func convertToImage(data: Data) -> UIImage? {
        let image = UIImage(data: data)
        return image
    }
}
