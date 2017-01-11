//
//  String+FirstLetter.swift
//  Campus Walk
//
//  Created by Shane Byers on 10/23/16.
//  Copyright © 2016 Shane Byers. All rights reserved.
//

import Foundation

extension String {
    func firstLetter() -> String? {
        if self.isEmpty {
            return nil
        } else {
            let firstCharacter = self.substring(to: self.characters.index(after: self.startIndex))
            if firstCharacter >= "0" && firstCharacter <= "9" {
                return "#"
            } else {
                return firstCharacter
            }
        }
    }
}
