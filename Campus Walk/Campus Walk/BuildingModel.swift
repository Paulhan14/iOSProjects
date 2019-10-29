//
//  BuildingModel.swift
//  Campus Walk
//
//  Created by Jiaxing Han on 10/17/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation

struct building: Codable, Equatable {
    var name: String
    var opp_bldg_code: Int
    var year_constructed: Int
    var latitude: Double
    var longitude: Double
    var photo: String
}

class BuildingModel {
    fileprivate var campusBuildings: [building]
    let buildingByInitial: [String: [building]]
    static let sharedInstance = BuildingModel()
    
    init() {
        let mainBundle = Bundle.main
        let url = mainBundle.url(forResource: "buildings", withExtension: "plist")
        do {
            let data = try Data(contentsOf: url!)
            let decoder = PropertyListDecoder()
            campusBuildings = try decoder.decode([building].self, from: data)
            var _buildingByInitial = [String: [building]]()
            for aBuilding in campusBuildings {
                let firstLetter = aBuilding.name.prefix(1).uppercased()
                if _buildingByInitial[firstLetter]?.append(aBuilding) == nil {
                    _buildingByInitial[firstLetter] = [aBuilding]
                }
            }
            buildingByInitial = _buildingByInitial
        } catch {
            print(error)
            campusBuildings = []
            buildingByInitial = [:]
        }
    }
    
    var numberOfKeys : Int {return buildingByInitial.keys.count}
    var buildingKeys: [String] {return buildingByInitial.keys.sorted()}
    
    func getBuildingBy(index: Int) -> building {
        return campusBuildings[index]
    }
    
    func numberOfBuildingsAtSection(index: Int) -> Int {
        let key = buildingKeys[index]
        return buildingByInitial[key]!.count
    }
    
    func buildingAt(_ indexPath: IndexPath) -> building {
        let key = buildingKeys[indexPath.section]
        return buildingByInitial[key]![indexPath.row]
    }
    
    func buildingNameAt(_ indexPath: IndexPath) -> String {
        let building = buildingAt(indexPath)
        return building.name
    }
    
    func yearBuiltAt(_ indexPath: IndexPath) -> Int {
        let building = buildingAt(indexPath)
        return building.year_constructed
    }
    
    func checkPhotoAt(_ indexPath: IndexPath) -> Bool {
        let building = buildingAt(indexPath)
        if building.photo == "" {
            return false
        }
        return true
    }
    
    func photoNameAt(_ indexPath: IndexPath) -> String {
        let building = buildingAt(indexPath)
        return building.photo
    }
}
