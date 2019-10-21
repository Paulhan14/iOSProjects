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
    
    func addBuildingToList(_ building: building) -> Bool {
        if favorites.contains(building) {
            return false
        }
        favorites.append(building)
        return true
    }
    
    func removeBuildingFromList(_ name: String){
        guard name != "" else {return}
        for i in 0..<favorites.count {
            if favorites[i].name == name {
                favorites.remove(at: i)
                return
            }
        }
    }
    
    func getFavoriteListSize() -> Int {
        return favorites.count
    }
    
    func getBuildingBy(_ index: Int) -> building {
        return favorites[index]
    }
    
    func getBuildingNameAt(_ index: Int) -> String {
        let building = getBuildingBy(index)
        return building.name
    }
}
