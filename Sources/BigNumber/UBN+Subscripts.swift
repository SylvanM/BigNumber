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
            // make sure the index is an actual value of the array
            if words.count > index {
                words[index] = newValue
                return
            }
            
            words += Words(repeating: 0, count: index - words.count) + [newValue]
        }
    }
    
    /// References a bit with a specified index
    subscript (bit index: Int) -> Words.Element {
        get {
            self & ( 1 << index ) != 0 ? 1 : 0
        }
        set {
            
            for _ in 0...(index / UInt.size) {
                self.words.append(0x0)
            }
            
            self &= ~(1 << index)
            self |= UBigNumber(newValue << index)
        
        }
    }
    
}
