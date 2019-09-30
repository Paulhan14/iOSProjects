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
    var count: Int
}

typealias Names = [String]

class ParkImageModel {
    
    private let parks: [StatePark]
    private let imageNames: [String:Names]
    
    init() {
        let mainBundle = Bundle.main
        let url = mainBundle.url(forResource: "Parks", withExtension: "plist")
        do {
            let data = try Data(contentsOf: url!)
            let decoder = PropertyListDecoder()
            parks = try decoder.decode([StatePark].self, from: data)
        } catch {
            print(error)
            parks = []
        }
        
        var _imageNames: [String:Names] = [:]
        for park in self.parks {
            var names: [String] = []
            for i in 0..<park.count {
                names.append("\(park.name)0\(i+1)")
            }
            _imageNames[park.name] = names
        }
        imageNames = _imageNames
    }
    
    func getParkNameAt(index: Int) -> String {
        return self.parks[index].name
    }
    
    func getParkImageCountAt(index: Int) -> Int {
        return self.parks[index].count
    }
    
    func getImageNameOfPark(name: String) -> [String] {
        return self.imageNames[name] ?? []
    }
    
    func getParkCount() -> Int {
        return self.parks.count
    }
}
