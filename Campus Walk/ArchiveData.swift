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
        let buildings = aDecoder.decodeObjectForKey(ArchiveKey.buildings) as! [Building]
        let showFavorites = aDecoder.decodeBoolForKey(ArchiveKey.showFavorites)
        let trackLocation = aDecoder.decodeBoolForKey(ArchiveKey.trackLocation)
        let showOriginalPictures = aDecoder.decodeBoolForKey(ArchiveKey.showOriginalPictures)
        let mapType : Int = aDecoder.decodeIntegerForKey(ArchiveKey.mapType)
        self.init(buildings:buildings, showFavorites: showFavorites, trackLocation: trackLocation, showOriginalPictures: showOriginalPictures, mapType: mapType)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(buildings, forKey: ArchiveKey.buildings)
        aCoder.encodeBool(showFavorites, forKey: ArchiveKey.showFavorites)
        aCoder.encodeBool(trackLocation, forKey: ArchiveKey.trackLocation)
        aCoder.encodeBool(showOriginalPictures, forKey: ArchiveKey.showOriginalPictures)
        aCoder.encodeInteger(mapType, forKey: ArchiveKey.mapType)
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
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(latitude, forKey: ArchiveKey.latitude)
        aCoder.encodeDouble(longitude, forKey: ArchiveKey.longitude)
        aCoder.encodeObject(name, forKey: ArchiveKey.name)
        aCoder.encodeInteger(yearConstructed, forKey: ArchiveKey.yearConstructed)
        aCoder.encodeObject(photoName, forKey: ArchiveKey.photoName)
        aCoder.encodeBool(isFavorite, forKey: ArchiveKey.isFavorite)
        aCoder.encodeInteger(buildingCode, forKey: ArchiveKey.buildingCode)
        if let updatedImage = self.updatedImage {
            aCoder.encodeObject(UIImagePNGRepresentation(updatedImage), forKey: ArchiveKey.updatedImage)
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let latitude = aDecoder.decodeDoubleForKey(ArchiveKey.latitude)
        let longitude = aDecoder.decodeDoubleForKey(ArchiveKey.longitude)
        let name = aDecoder.decodeObjectForKey(ArchiveKey.name) as! String
        let yearConstructed : Int = aDecoder.decodeIntegerForKey(ArchiveKey.yearConstructed)
        let photoName = aDecoder.decodeObjectForKey(ArchiveKey.photoName) as! String
        let isFavorite = aDecoder.decodeBoolForKey(ArchiveKey.isFavorite)
        let buildingCode : Int = aDecoder.decodeIntegerForKey(ArchiveKey.buildingCode)
        let updatedImage = aDecoder.decodeObjectForKey(ArchiveKey.updatedImage) as! NSData?
        
        if let updatedImage = updatedImage {
            self.init(name: name, buildingCode: buildingCode, yearConstructed: yearConstructed, latitude: latitude, longitude: longitude, photoName: photoName, isFavorite: isFavorite, updatedImage: UIImage(data: updatedImage))
        } else {
            self.init(name: name, buildingCode: buildingCode, yearConstructed: yearConstructed, latitude: latitude, longitude: longitude, photoName: photoName, isFavorite: isFavorite, updatedImage: nil)
        }
        
    }
}
