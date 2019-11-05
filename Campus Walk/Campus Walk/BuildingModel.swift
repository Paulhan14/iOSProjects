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
    var buildingDescriptions: [String: String]
    static let sharedInstance = BuildingModel()
    var filteredBuildings = [building]()
    var indexPathOfBuilding = [String: IndexPath]()
    
    init() {
        let mainBundle = Bundle.main
        let url = mainBundle.url(forResource: "buildings", withExtension: "plist")
        do {
            let data = try Data(contentsOf: url!)
            let decoder = PropertyListDecoder()
            campusBuildings = try decoder.decode([building].self, from: data)
            var _buildingByInitial = [String: [building]]()
            var _buildingDescriptions = [String: String]()
            for aBuilding in campusBuildings {
                let firstLetter = aBuilding.name.prefix(1).uppercased()
                if _buildingByInitial[firstLetter]?.append(aBuilding) == nil {
                    _buildingByInitial[firstLetter] = [aBuilding]
                }
                _buildingDescriptions[aBuilding.name] = ""
            }
            buildingByInitial = _buildingByInitial
            buildingDescriptions = _buildingDescriptions
            setIndexPathOfBuilding()
        } catch {
            print(error)
            campusBuildings = []
            buildingByInitial = [:]
            buildingDescriptions = [:]
        }
    }
    
    var numberOfKeys : Int {return buildingByInitial.keys.count}
    var buildingKeys: [String] {return buildingByInitial.keys.sorted()}
    var numberOfBuildings: Int {return campusBuildings.count}
    
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
    
    func getBuildingDescription(_ indexPath: IndexPath) -> String {
        let building = buildingAt(indexPath)
        return buildingDescriptions[building.name]!
    }
    
    func setBuildingDescription(_ indexPath: IndexPath, _ content: String) {
        let building = buildingAt(indexPath)
        buildingDescriptions[building.name]! = content
    }
    
    func filter(_ aFilter: (_ building:building) -> Bool ) -> [building] {
        var filtered = [building]()
        for aBuilding in self.campusBuildings {
            if aFilter(aBuilding) {
                filtered.append(aBuilding)
            }
        }
        return filtered
    }
    
    func setIndexPathOfBuilding() {
        for aBuilding in self.campusBuildings {
            let firstLetter = aBuilding.name.prefix(1).uppercased()
            let name = aBuilding.name
            var keys = buildingByInitial.keys.sorted()
            var section = 0
            var row = 0
            for i in 0..<keys.count {
                if keys[i] == firstLetter {
                    section = i
                    break
                }
            }
            
            for i in 0..<buildingByInitial[firstLetter]!.count {
                if buildingByInitial[firstLetter]![i].name == name {
                    row = i
                    break
                }
            }
            let _indexPath = IndexPath(row: row, section: section)
            indexPathOfBuilding[name] = _indexPath
        }
        
        
    }
    
    func getIndexPathOfBuildingWith(_ name: String) -> IndexPath {
        return self.indexPathOfBuilding[name]!
    }
}
