//
//  DirectionInstructionsTableViewController.swift
//  Campus Walk
//
//  Created by Shane Byers on 10/29/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import UIKit

class DirectionInstructionsTableViewController: UITableViewController {
    
    let directionModel = DirectionModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directionModel.numberOfInstructions()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstructionCell", for: indexPath)
        
        let instructions = directionModel.instructionsAtIndex(indexPath.row)
        
        cell.textLabel!.text = instructions
        
        return cell
    }
}
