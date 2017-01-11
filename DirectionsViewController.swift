//
//  DirectionsViewController.swift
//  Campus Walk
//
//  Created by Shane Byers on 10/29/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import UIKit

class DirectionsViewController: UIViewController {
    
    @IBOutlet weak var originTextField: UITextField!
    
    @IBOutlet weak var destinationTextField: UITextField!

    @IBOutlet weak var directionsButton: UIButton!
    
    let model = BuildingModel.sharedInstance
    
    var source : Building?
    var destination : Building?
    
    var lastTappedTextField : UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func textFieldDidBeginEditing(sender: UITextField) {
        
        lastTappedTextField = sender
        
        sender.endEditing(true)
        
        let actionController = UIAlertController()
        
        let currentLocationAction = UIAlertAction(title: "Use Current Location", style: .Default) { (action) in
            self.lastTappedTextField?.text = "Current Location"
        }
        
        actionController.addAction(currentLocationAction)
        
        let chooseBuildingAction = UIAlertAction(title: "Choose a Building", style: .Default) { (action) in
            self.performSegueWithIdentifier("showBuildingsForDirections", sender: self)
        }
        
        actionController.addAction(chooseBuildingAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionController.addAction(cancelAction)
        
        presentViewController(actionController, animated: true, completion: nil)
        
        
        performSegueWithIdentifier("showBuildingsForDirections", sender: self)
        
        
    }
    
    func setTextField(building: Building) {
        lastTappedTextField?.text = building.name
        
        if lastTappedTextField!.tag == 0 {
            source = building
        } else {
            destination = building
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "showBuildingsForDirections":
            break
        case "unwindToMap":
            let destinationViewController = segue.destinationViewController as! MapViewController
            
            destinationViewController.sourceAndDestination(source, destination: destination)
            
        default:
            assert(false, "Unhandled Segue")
        }
    }
    
    @IBAction func getDirectionsButtonTapped(sender: UIButton) {
        if originTextField.text != originTextField.placeholder! {
            if destinationTextField.text != destinationTextField.placeholder! {
                performSegueWithIdentifier("unwindToMap", sender: self)
            } else {
                sendAlert("Missing Destination", message: "Please select a destination.")
            }
        } else {
            sendAlert("Missing Source", message: "Please select a source.")
        }
    }
    
    @IBAction func dismissListOfBuildings(segue: UIStoryboardSegue) {
        
    }
    
    func sendAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
        
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
