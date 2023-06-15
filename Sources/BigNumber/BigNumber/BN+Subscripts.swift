//
//  File.swift
//  
//
//  Created by Sylvan Martin on 5/31/22.
//

import Foundation

public extension BigNumber {
    
    // MARK: - Subscripts
    
    /// References the word at the given index
    subscript (index: Int) -> UInt {
        get { magnitude[index] }
        set { magnitude[index] = newValue }
    }
    
    /// References the array value at the given index. If the index does not exist, it creates it or returns 0.
    subscript (safe index: Int) -> WordType {
        get { magnitude[safe: index] }
        set { magnitude[safe: index] = newValue }
    }
    
    /// References a bit with a specified index
    subscript (bit index: Int) -> Words.Element {
        get { magnitude[bit: index] }
        set { magnitude[bit: index] = newValue }
    }
    
}
