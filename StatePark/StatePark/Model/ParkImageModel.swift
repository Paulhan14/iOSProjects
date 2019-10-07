//
//  ParkImageModel.swift
//  StatePark
//
//  Created by Jiaxing Han on 9/25/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation

struct StatePark: Codable {
    var name: String
    var photos: [Photo]
}

struct Photo: Codable {
    var imageName: String
    var caption: String
}


class ParkImageModel {
    
    private let parks: [StatePark]
    
    init() {
        let mainBundle = Bundle.main
        let url = mainBundle.url(forResource: "StateParks", withExtension: "plist")
        do {
            let data = try Data(contentsOf: url!)
            let decoder = PropertyListDecoder()
            parks = try decoder.decode([StatePark].self, from: data)
        } catch {
            print(error)
            parks = []
        }
    }
    
    func getParkNameAt(index: Int) -> String {
        return self.parks[index].name
    }
    
    func getParkImageCountAt(index: Int) -> Int {
        return self.parks[index].photos.count
    }
    
    func getImageNameOfParkAt(index: Int) -> [String] {
        var _imageNames: [String] = []
        for photo in self.parks[index].photos {
            _imageNames.append(photo.imageName)
        }
        return _imageNames
    }
    
    func getParkCount() -> Int {
        return self.parks.count
    }
    
    func getCaptionsOfParkAt(index: Int) -> [String] {
        var _captions: [String] = []
        for photo in self.parks[index].photos {
            _captions.append(photo.caption)
        }
        return _captions
    }
}
