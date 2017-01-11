//
//  TableViewController.swift
//  Campus Walk
//
//  Created by Shane Byers on 10/23/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    let model = BuildingModel.sharedInstance
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.buildingsCountForSection(section)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return model.numberOfSections()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.letterForSection(section)
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return model.letters()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BuildingCell", forIndexPath: indexPath)
        
        let building = model.buildingInSection(indexPath.section, row: indexPath.row)
        
        cell.textLabel!.text = building.name
        
        if building.yearConstructed != 0 {
            cell.detailTextLabel!.text = "Constructed in \(building.yearConstructed)"
        } else {
            cell.detailTextLabel!.text = ""
        }
        
        if model.showOriginalPictures {
            if building.photoName != "" {
                cell.imageView!.image = UIImage(named: building.photoName)
            }
        } else {
            if building.updatedImage != nil {
                cell.imageView!.image = building.updatedImage
            } else if building.photoName != "" {
                cell.imageView!.image = UIImage(named: building.photoName)
            }
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case "MapSegue":
                
                if let cell = sender as? UITableViewCell {
                    let indexPath = tableView.indexPathForCell(cell)
                    self.model.selectBuildingWithIndexPath(indexPath!)
                }
            case "unwindToDirections":
                let destination = segue.destinationViewController as! DirectionsViewController
                
                let indexPath = tableView.indexPathForSelectedRow!
                let section = indexPath.section
                let row = indexPath.row
                let building = model.buildingInSection(section, row: row)
                
                destination.setTextField(building)
                
            default:
                assert(false, "Unhandled Segue")
            }
        }
    }
}
