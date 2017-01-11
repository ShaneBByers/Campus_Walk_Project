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
    
    
    @IBAction func textFieldDidBeginEditing(_ sender: UITextField) {
        
        lastTappedTextField = sender
        
        sender.endEditing(true)
        
        let actionController = UIAlertController()
        
        let currentLocationAction = UIAlertAction(title: "Use Current Location", style: .default) { (action) in
            self.lastTappedTextField?.text = "Current Location"
        }
        
        actionController.addAction(currentLocationAction)
        
        let chooseBuildingAction = UIAlertAction(title: "Choose a Building", style: .default) { (action) in
            self.performSegue(withIdentifier: "showBuildingsForDirections", sender: self)
        }
        
        actionController.addAction(chooseBuildingAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionController.addAction(cancelAction)
        
        present(actionController, animated: true, completion: nil)
        
        
        performSegue(withIdentifier: "showBuildingsForDirections", sender: self)
        
        
    }
    
    func setTextField(_ building: Building) {
        lastTappedTextField?.text = building.name
        
        if lastTappedTextField!.tag == 0 {
            source = building
        } else {
            destination = building
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "showBuildingsForDirections":
            break
        case "unwindToMap":
            let destinationViewController = segue.destination as! MapViewController
            
            destinationViewController.sourceAndDestination(source, destination: destination)
            
        default:
            assert(false, "Unhandled Segue")
        }
    }
    
    @IBAction func getDirectionsButtonTapped(_ sender: UIButton) {
        if originTextField.text != originTextField.placeholder! {
            if destinationTextField.text != destinationTextField.placeholder! {
                performSegue(withIdentifier: "unwindToMap", sender: self)
            } else {
                sendAlert("Missing Destination", message: "Please select a destination.")
            }
        } else {
            sendAlert("Missing Source", message: "Please select a source.")
        }
    }
    
    @IBAction func dismissListOfBuildings(_ segue: UIStoryboardSegue) {
        
    }
    
    func sendAlert(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
