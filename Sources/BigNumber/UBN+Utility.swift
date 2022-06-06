//
//  File.swift
//  
//
//  Created by Sylvan Martin on 5/5/20.
//

import Foundation

public extension UBigNumber {
    
    // MARK: Utility Methods
    
    /**
     * Gets rid of extraneous leading zeroes
     *
     * - Returns: The normalized version of this `UBigNumber`
     */
    @discardableResult mutating func normalize() -> UBigNumber {
        
        // this should never happen
        if words.count == 0 {
            words = [0]
            return self
        }
        
        while mostSignificantWord == 0 && size > 1 {
            words.removeLast()
        }
        
        return self
    }
    
    /// Hashes the ```UBigNumber```
    func hash(into hasher: inout Hasher) {
        for element in words {
            hasher.combine(element)
        }
    }
    
    /**
     * Generates a random `UBN`
     *
     * - Parameters:
     *      - size: The maximum number of words in the random `UBN` to be generated
     *
     * - Returns: A `UBN` with a random value
     */
    static func random(size: Int, generator: SecRandomRef? = kSecRandomDefault) -> UBigNumber {
        let words = [WordType](repeating: 0, count: size)
        var a = UBN()
        a.words = words
        _ = SecRandomCopyBytes(generator, a.sizeInBytes, &a.words)
        return a.normalize()
    }
    
    @discardableResult
    mutating func setToZero() -> UBigNumber {
        self.words = [0]
        return self
    }
    
}
