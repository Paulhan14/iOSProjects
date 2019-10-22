//
//  FavoriteModel.swift
//  Campus Walk
//
//  Created by Jiaxing Han on 10/19/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation

class FavoriteModel {
    private var favorites: [building]
    static let theFavoriteModel = FavoriteModel()
    
    init() {
        favorites = []
    }
    
    // Add a building
    func addBuildingToList(_ building: building) -> Bool {
        if favorites.contains(building) {
            return false
        }
        favorites.append(building)
        return true
    }
    
    // Delete a building from the list
    func removeBuildingFromList(_ name: String){
        guard name != "" else {return}
        for i in 0..<favorites.count {
            if favorites[i].name == name {
                favorites.remove(at: i)
                return
            }
        }
    }
    
    // Get total size of favorite list
    func getFavoriteListSize() -> Int {
        return favorites.count
    }
    
    // Get the building object based on index
    func getBuildingBy(_ index: Int) -> building {
        return favorites[index]
    }
    
    // Get the building name based on index
    func getBuildingNameAt(_ index: Int) -> String {
        let building = getBuildingBy(index)
        return building.name
    }
    
    // Check if the building is in the favorite list
    func checkTheBuildingWith(name: String) -> Bool {
        for item in favorites {
            if item.name == name {
                return true
            }
        }
        return false
    }
}
