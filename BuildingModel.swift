//
//  BuildingModel.swift
//  Campus Walk
//
//  Created by Shane Byers on 10/23/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import Foundation

struct MapRegion {
    let latitude : Double
    let longitude : Double
    let latitudeDelta : Double
    let longitudeDelta : Double
    
    init(latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }
}


class BuildingModel {
    static let sharedInstance = BuildingModel()
    
    let plistName = "buildings"
    
    let buildingsData : [Building]
    
    var buildingsDictionary : [String:[Building]]
    
    var allKeys : [String]
    
    var defaultBuildings = [Building]()
    
    var favoriteBuildings = [Building]()
    
    let favoriteLetter = "⭐️"
    
    var currentMapRegion : MapRegion
    
    let defaultMapRegion = MapRegion(latitude: 40.8, longitude: -77.86, latitudeDelta: 0.025, longitudeDelta: 0.025)
    
    var showFavorites : Bool
    
    var trackLocation : Bool
    
    var showOriginalPictures : Bool
    
    var mapType : Int
    
    var buildingsURL : URL
    
    let archive : Archive
    
    let noImagePhotoName = "NoImageAvailable.jpg"
    
    init() {
        
        showFavorites = true
        
        trackLocation = false
        
        showOriginalPictures = false
        
        mapType = 0
        
        let fileManager = FileManager.default
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        buildingsURL = documentURL.appendingPathComponent(plistName + ".archive")
        
        let fileExists = fileManager.fileExists(atPath: buildingsURL.path)
        
        if fileExists {
            
            archive = NSKeyedUnarchiver.unarchiveObject(withFile: buildingsURL.path)! as! Archive
            buildingsData = archive.buildings
            showFavorites = archive.showFavorites
            trackLocation = archive.trackLocation
            showOriginalPictures = archive.showOriginalPictures
            mapType = archive.mapType
            
        } else {
            let path = Bundle.main.path(forResource: plistName, ofType: "plist")
            let data = NSArray(contentsOfFile: path!) as! [[String:AnyObject]]
            
            var _buildings = [Building]()
            
            for dictionary in data {
                let name = dictionary["name"] as! String
                let buildingCode = dictionary["opp_bldg_code"] as! Int
                let yearConstructed = dictionary["year_constructed"] as! Int
                let latitude = dictionary["latitude"] as! Double
                let longitude = dictionary["longitude"] as! Double
                var photoName = dictionary["photo"] as! String
                if photoName != "" {
                    photoName = "\(photoName).jpg"
                }
                let aBuilding = Building(name: name, buildingCode: buildingCode, yearConstructed: yearConstructed, latitude: latitude, longitude: longitude, photoName: photoName, isFavorite: false, updatedImage: nil)
                
                _buildings.append(aBuilding)
            }
            
            buildingsData = _buildings
            
            archive = Archive(buildings: buildingsData, showFavorites: showFavorites, trackLocation: trackLocation, showOriginalPictures: showOriginalPictures, mapType: mapType)
            NSKeyedArchiver.archiveRootObject(archive, toFile: buildingsURL.path)
        }
        
        var _buildingsDictionary = [String:[Building]]()
        
        for building in buildingsData {
            let firstLetter = building.name.firstLetter()!
            
            if let _ = _buildingsDictionary[firstLetter] {
                _buildingsDictionary[firstLetter]!.append(building)
            } else {
                _buildingsDictionary[firstLetter] = [building]
            }
        }
        
        buildingsDictionary = _buildingsDictionary
        let keys = Array(buildingsDictionary.keys)
        allKeys = keys.sorted()
        currentMapRegion = defaultMapRegion
        
        for building in buildingsData {
            if building.isFavorite {
                self.addFavoriteBuildingWithName(building.name)
            }
        }
    }
    
    func buildingsCountForSection(_ section:Int) -> Int {
        let letterInSection = letterForSection(section)
        let buildingsInSection = buildingsDictionary[letterInSection]!
        return buildingsInSection.count
    }
    
    func letterForSection(_ section:Int) -> String {
        return allKeys[section]
    }
    
    func numberOfSections() -> Int {
        return allKeys.count
    }
    
    func letters() -> [String] {
        return allKeys
    }
    
    func buildingInSection(_ section: Int, row: Int) -> Building {
        
        let titleInSection = allKeys[section]
        
        let buildingsInSection = buildingsDictionary[titleInSection]!
        
        return buildingsInSection[row]
    }
    
    func addFavoriteBuildingWithName(_ name: String) {
        if favoriteBuildings.count == 0 {
            allKeys.insert(favoriteLetter, at: 0)
            
        }
        let firstLetter = name.firstLetter()
        let buildingsInSection = buildingsDictionary[firstLetter!]!
        
        for building in buildingsInSection {
            if building.name == name {
                
                building.isFavorite = true
                favoriteBuildings.append(building)
                if let index = defaultBuildings.index(of: building) {
                    defaultBuildings.remove(at: index)
                }
            }
        }

        
        buildingsDictionary[favoriteLetter] = favoriteBuildings
        
        deleteDefaultBuildingWithName(name)
        
        saveArchive()
        
    }
    
    func deleteFavoriteBuildingWithName(_ name: String) {
        for (i, building) in favoriteBuildings.enumerated() {
            if building.name == name {
                
                building.isFavorite = false
                
                favoriteBuildings.remove(at: i)
                defaultBuildings.append(building)
            }
        }
        
        buildingsDictionary[favoriteLetter] = favoriteBuildings
        
        if favoriteBuildings.count == 0 {
            allKeys.remove(at: 0)
            buildingsDictionary.removeValue(forKey: favoriteLetter)
        }
        
        saveArchive()
    }
    
    func deleteDefaultBuildingWithName(_ name: String) {
        for (i, building) in defaultBuildings.enumerated() {
            if building.name == name {
                
                defaultBuildings.remove(at: i)
            }
        }
    }
    
    func selectBuildingWithIndexPath(_ indexPath : IndexPath) -> Building {
        let titleInSection = allKeys[indexPath.section]
        
        let buildingsInSection = buildingsDictionary[titleInSection]!
        
        let building = buildingsInSection[indexPath.row]
        
        defaultBuildings.append(building)
        
        return building
    }
    
    func selectBuildingWithIndexPathNoReturn(_ indexPath : IndexPath) {
        let titleInSection = allKeys[indexPath.section]
        
        let buildingsInSection = buildingsDictionary[titleInSection]!
        
        let building = buildingsInSection[indexPath.row]
        
        defaultBuildings.append(building)
    }
    
    func buildingWithName(_ name: String) -> Building? {
        let firstLetter = name.firstLetter()
        
        let buildingsInSection = buildingsDictionary[firstLetter!]!

        
        for building in buildingsInSection {
            if building.name == name {
                return building
            }
        }
        
        return nil
    }
    
    func favorites() -> [Building] {
        return favoriteBuildings
    }
    
    func defaults() -> [Building] {
        return defaultBuildings
    }
    
    func updateCurrentLocation(_ latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) {
        currentMapRegion = MapRegion(latitude: latitude, longitude: longitude, latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
    
    func removeBuildingWithName(_ name: String) {
        deleteFavoriteBuildingWithName(name)
        deleteDefaultBuildingWithName(name)
    }
    
    func setPreferences(_ showFavorites: Bool, trackLocation: Bool, showOriginalPictures: Bool, mapType: Int) {
        self.showFavorites = showFavorites
        self.trackLocation = trackLocation
        self.showOriginalPictures = showOriginalPictures
        self.mapType = mapType
        
        archive.showFavorites = showFavorites
        archive.trackLocation = trackLocation
        archive.showOriginalPictures = showOriginalPictures
        archive.mapType = mapType
        
        saveArchive()
    }
    
    func saveArchive() {
        
        NSKeyedArchiver.archiveRootObject(archive, toFile: buildingsURL.path)
    }


}
