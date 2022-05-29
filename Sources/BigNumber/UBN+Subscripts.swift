//
//  File.swift
//  
//
//  Created by Sylvan Martin on 5/5/20.
//

import Foundation

public extension UBigNumber {
    
    // MARK: - Subscripts
    
    /// References the word at the given index
    subscript (index: Int) -> UInt {
        get { words[index] }
        set { words[index] = newValue }
    }
    
    /// References the array value at the given index. If the index does not exist, it creates it or returns 0.
    subscript (safe index: Int) -> UInt {
        get { words.count > index ? words[index] : 0 }
        set {
            
            // if the index is negative, just ignore it
            if index < 0 {
                return
            }
            
            // make sure the index is an actual value of the array
            if words.count > index {
                words[index] = newValue
                normalize()
                return
            }
            
            words += Words(repeating: 0, count: index - words.count) + [newValue]
            
        }
    }
    
    /// References a bit with a specified index
    subscript (bit index: Int) -> Words.Element {
        get {
            let division  = index.quotientAndRemainder(dividingBy: UInt.bitSize)
            let wordIndex = division.quotient
            let bitIndex  = division.remainder
            
            return self[safe: wordIndex] & (1 << bitIndex) != 0 ? 1 : 0
        }
        set {
            
            let division  = index.quotientAndRemainder(dividingBy: UInt.bitSize)
            let wordIndex = division.quotient
            let bitIndex  = division.remainder
            
            if wordIndex >= self.size {
                self.words += Words(repeating: 0, count: wordIndex - self.size + 1)
            }
            
            if newValue == 0 {
                self[wordIndex] &= ~(1 << bitIndex) // set bit to 0
            } else {
                self[wordIndex] |= 1 << bitIndex // set bit to 1
            }
            
            normalize()
        
        }
    }
    
}
