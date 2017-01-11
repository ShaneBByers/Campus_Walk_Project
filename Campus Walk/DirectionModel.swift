//
//  DirectionModel.swift
//  Campus Walk
//
//  Created by Shane Byers on 10/29/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import Foundation

class DirectionModel {
    static let sharedInstance = DirectionModel()
    
    private var instructionList = [String]()
    
    func updateInstructionsList(newList : [String]) {
        instructionList = newList
    }
    
    func instructions() -> [String] {
        return instructionList
    }
    
    func instructionsAtIndex(index: Int) -> String {
        return instructionList[index]
    }
    
    func numberOfInstructions() -> Int {
        return instructionList.count
    }
}
