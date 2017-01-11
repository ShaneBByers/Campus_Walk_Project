//
//  BuildingDetailsViewController.swift
//  Campus Walk
//
//  Created by Shane Byers on 10/30/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import UIKit
import Photos

class BuildingDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let model = BuildingModel.sharedInstance
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearConstructedLabel: UILabel!
    
    var buildingName : String?
    var yearConstructed : String?
    var buildingImage : UIImage?
    var buildingImageView = UIImageView()
    
    let topBufferDistance : CGFloat = 20.0
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = buildingName
        yearConstructedLabel.text = yearConstructed
        
        imagePicker.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        buildingImageView.center.y = self.view.center.y/2.0 + topBufferDistance
        buildingImageView.center.x = self.view.center.x
        
        let widthScaleFactor = self.view.frame.width/buildingImageView.frame.width
        let heightScaleFactor = (self.view.frame.height/2.0 - topBufferDistance)/buildingImageView.frame.height
        
        let scaleFactor = min(widthScaleFactor,heightScaleFactor)
        
        buildingImageView.frame.size.height *= scaleFactor
        buildingImageView.frame.size.width *= scaleFactor
        
        self.view.addSubview(buildingImageView)
    }
    
    func insertImage(image: UIImage) {
        buildingImageView.removeFromSuperview()
        buildingImageView = UIImageView(image: image)
        buildingImageView.center.y = self.view.center.y/2.0 + topBufferDistance
        buildingImageView.center.x = self.view.center.x
        
        let widthScaleFactor = self.view.frame.width/buildingImageView.frame.width
        let heightScaleFactor = (self.view.frame.height/2.0 - topBufferDistance)/buildingImageView.frame.height
        
        let scaleFactor = min(widthScaleFactor,heightScaleFactor)
        
        buildingImageView.frame.size.height *= scaleFactor
        buildingImageView.frame.size.width *= scaleFactor
        
    }
    
    func configureWithBuildigName(name: String, constructedInYear year: String, withImage buildingImage: UIImage) {
        buildingName = name
        yearConstructed = year
        
        self.buildingImage = buildingImage
        
        buildingImageView = UIImageView(image: buildingImage)
    }
    
    @IBAction func updateImageButtonTapped(sender: AnyObject) {
        
        let actionController = UIAlertController()
        
        
        /* I would test this feature that checks if the camera
           is available on my iPhone, but since Xcode cannot be
           updated for this class, I can't test it on my iOS 10 phone. */
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            
            let cameraAction = UIAlertAction(title: "Take a Picture", style: .Default) { (action) in
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = .Camera
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            
            actionController.addAction(cameraAction)
            
            let selectPhotoAction = UIAlertAction(title: "Select a Photo", style: .Default) { (action) in
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            
            actionController.addAction(selectPhotoAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            actionController.addAction(cancelAction)
            
            presentViewController(actionController, animated: true, completion: nil)
            
        } else {
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        insertImage(image)
        let building = model.buildingWithName(buildingName!)
        building!.updatedImage = image
        model.saveArchive()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
