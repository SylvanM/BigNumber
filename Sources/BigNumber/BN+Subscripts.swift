//
//  File.swift
//  
//
//  Created by Sylvan Martin on 5/7/20.
//

import Foundation

public extension BigNumber {
    
    // MARK: - Subscripts
    
    /// References the word at the given index
    subscript (index: Int) -> UInt {
        get { magnitude.words[index] }
        set {
            magnitude.words[index] = newValue
            #warning("Gotta worry about signs here!")
        }
    }
    
    /// Safely references the word at the given index
    subscript (safe index: Int) -> UInt {
        get { magnitude[safe: index] }
        set { magnitude[safe: index] = newValue }
    }
    
    /// References a bit with a specified index
    subscript (bit index: Int) -> Words.Element {
        get { magnitude[bit: index] }
        set { magnitude[bit: index] = newValue }
    }
    
}
