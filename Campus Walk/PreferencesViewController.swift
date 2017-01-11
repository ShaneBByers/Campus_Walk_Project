//
//  PreferencesViewController.swift
//  Campus Walk
//
//  Created by Shane Byers on 11/6/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import UIKit



class PreferencesViewController: UIViewController {
    
    let model = BuildingModel.sharedInstance

    @IBOutlet weak var showFavoritesSwitch: UISwitch!
    
    @IBOutlet weak var trackLocationSwitch: UISwitch!
    
    @IBOutlet weak var showOriginalPicturesSwitch: UISwitch!
    
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    
    var showFavorites : Bool?
    
    var trackLocation : Bool?
    
    var showOriginalPictures : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showFavoritesSwitch.on = model.showFavorites
        trackLocationSwitch.on = model.trackLocation
        showOriginalPicturesSwitch.on = model.showOriginalPictures
        mapTypeSegmentedControl.selectedSegmentIndex = model.mapType
    }
    
    @IBAction func dismissButtonPressed(sender: UIButton) {
        model.setPreferences(showFavoritesSwitch.on, trackLocation: trackLocationSwitch.on, showOriginalPictures: showOriginalPicturesSwitch.on, mapType: mapTypeSegmentedControl.selectedSegmentIndex)
    }
}
