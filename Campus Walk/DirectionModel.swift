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
    
    fileprivate var instructionList = [String]()
    
    func updateInstructionsList(_ newList : [String]) {
        instructionList = newList
    }
    
    func instructions() -> [String] {
        return instructionList
    }
    
    func instructionsAtIndex(_ index: Int) -> String {
        return instructionList[index]
    }
    
    func numberOfInstructions() -> Int {
        return instructionList.count
    }
}
