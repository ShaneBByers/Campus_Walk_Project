//
//  ArchiveData.swift
//  Campus Walk
//
//  Created by Shane Byers on 11/7/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import Foundation
import UIKit

struct ArchiveKey {
    static let buildings = "buildings"
    static let showFavorites = "showFavorites"
    static let trackLocation = "trackLocation"
    static let showOriginalPictures = "showOriginalPictures"
    static let updatedPictures = "updatedPictures"
    static let mapType = "mapType"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let name = "name"
    static let yearConstructed = "yearConstructed"
    static let photoName = "photoName"
    static let isFavorite = "isFavorite"
    static let buildingCode = "buildingCode"
    static let updatedImage = "updatedImage"
}

class Archive : NSObject, NSCoding {
    let buildings : [Building]
    var showFavorites : Bool
    var trackLocation : Bool
    var showOriginalPictures : Bool
    var mapType : Int
    init(buildings:[Building], showFavorites: Bool, trackLocation: Bool, showOriginalPictures: Bool, mapType: Int) {
        self.buildings = buildings
        self.showFavorites = showFavorites
        self.trackLocation = trackLocation
        self.showOriginalPictures = showOriginalPictures
        self.mapType = mapType
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let buildings = aDecoder.decodeObject(forKey: ArchiveKey.buildings) as! [Building]
        let showFavorites = aDecoder.decodeBool(forKey: ArchiveKey.showFavorites)
        let trackLocation = aDecoder.decodeBool(forKey: ArchiveKey.trackLocation)
        let showOriginalPictures = aDecoder.decodeBool(forKey: ArchiveKey.showOriginalPictures)
        let mapType : Int = aDecoder.decodeInteger(forKey: ArchiveKey.mapType)
        self.init(buildings:buildings, showFavorites: showFavorites, trackLocation: trackLocation, showOriginalPictures: showOriginalPictures, mapType: mapType)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(buildings, forKey: ArchiveKey.buildings)
        aCoder.encode(showFavorites, forKey: ArchiveKey.showFavorites)
        aCoder.encode(trackLocation, forKey: ArchiveKey.trackLocation)
        aCoder.encode(showOriginalPictures, forKey: ArchiveKey.showOriginalPictures)
        aCoder.encode(mapType, forKey: ArchiveKey.mapType)
    }
    
}


class Building: NSObject, NSCoding {
    let name: String
    let buildingCode: Int
    let yearConstructed: Int
    let latitude: Double
    let longitude: Double
    
    let photoName: String
    
    var updatedImage : UIImage?
    
    var isFavorite : Bool
    
    
    init(name: String, buildingCode: Int, yearConstructed: Int, latitude: Double, longitude: Double, photoName:String, isFavorite: Bool, updatedImage: UIImage?) {
        self.name = name
        self.buildingCode = buildingCode
        self.yearConstructed = yearConstructed
        self.latitude = latitude
        self.longitude = longitude
        self.photoName = photoName
        self.isFavorite = isFavorite
        if let updatedImage = updatedImage {
            self.updatedImage = updatedImage
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(latitude, forKey: ArchiveKey.latitude)
        aCoder.encode(longitude, forKey: ArchiveKey.longitude)
        aCoder.encode(name, forKey: ArchiveKey.name)
        aCoder.encode(yearConstructed, forKey: ArchiveKey.yearConstructed)
        aCoder.encode(photoName, forKey: ArchiveKey.photoName)
        aCoder.encode(isFavorite, forKey: ArchiveKey.isFavorite)
        aCoder.encode(buildingCode, forKey: ArchiveKey.buildingCode)
        if let updatedImage = self.updatedImage {
            aCoder.encode(UIImagePNGRepresentation(updatedImage), forKey: ArchiveKey.updatedImage)
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let latitude = aDecoder.decodeDouble(forKey: ArchiveKey.latitude)
        let longitude = aDecoder.decodeDouble(forKey: ArchiveKey.longitude)
        let name = aDecoder.decodeObject(forKey: ArchiveKey.name) as! String
        let yearConstructed : Int = aDecoder.decodeInteger(forKey: ArchiveKey.yearConstructed)
        let photoName = aDecoder.decodeObject(forKey: ArchiveKey.photoName) as! String
        let isFavorite = aDecoder.decodeBool(forKey: ArchiveKey.isFavorite)
        let buildingCode : Int = aDecoder.decodeInteger(forKey: ArchiveKey.buildingCode)
        let updatedImage = aDecoder.decodeObject(forKey: ArchiveKey.updatedImage) as! Data?
        
        if let updatedImage = updatedImage {
            self.init(name: name, buildingCode: buildingCode, yearConstructed: yearConstructed, latitude: latitude, longitude: longitude, photoName: photoName, isFavorite: isFavorite, updatedImage: UIImage(data: updatedImage))
        } else {
            self.init(name: name, buildingCode: buildingCode, yearConstructed: yearConstructed, latitude: latitude, longitude: longitude, photoName: photoName, isFavorite: isFavorite, updatedImage: nil)
        }
        
    }
}
