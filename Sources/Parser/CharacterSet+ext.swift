//
//  CharacterSet+ext.swift
//  
//
//  Created by Sven A. Schmidt on 04/01/2020.
//

import Foundation


extension CharacterSet {
    public func contains(character: Character) -> Bool {
        if character.unicodeScalars.count <= 1 {
            return character.unicodeScalars.allSatisfy(contains(_:))
        } else {
            let testSet = CharacterSet(charactersIn: String(character))
            return testSet.isSubset(of: self)
        }
    }
}
