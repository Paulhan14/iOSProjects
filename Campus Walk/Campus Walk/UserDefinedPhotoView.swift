//
//  UserDefinedPhotoView.swift
//  Campus Walk
//
//  Created by Jiaxing Han on 10/28/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation
import UIKit

class UserDefinedPhoto {
    private var changedPhotos: [IndexPath: UIImage]
    static let userDefined = UserDefinedPhoto()
    
    init() {
        changedPhotos = [IndexPath: UIImage]()
    }
    
    func addOrChangePhoto(indexPath: IndexPath, image: UIImage) {
        changedPhotos[indexPath] = image
    }
    
    func getPhotoAt(indexPath: IndexPath) -> UIImage? {
        return changedPhotos[indexPath]
    }
}
