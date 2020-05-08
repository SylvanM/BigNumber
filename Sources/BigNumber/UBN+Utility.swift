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
        // A number of a fixed size is expected to have some empty elements, so leave it alone
        
        // this should never happen
        if words.count == 0 {
            words = [0]
            return self
        }
        
        while words.last! == 0 && words.count > 1 {
            words.removeLast()
        }
        
        return self
    }
    
    /// Hashes the ```UBigNumber```
    func hash(into hasher: inout Hasher) {
        let norm = normalized
        
        for element in norm.words {
            hasher.combine(element)
        }
    }
    
    /// Sets all bytes of this number to random data generated by Apple's secure CPRNG
    ///
    /// - Parameters:
    ///     - generator: optional `SecRandomRef `, defaulted to `kSecRandomDefault`
    mutating func setToRandom(generator: SecRandomRef? = kSecRandomDefault) {
        _ = SecRandomCopyBytes(generator, sizeInBytes, &words)
    }
    
    /**
     * Quickly set the numerical value of this `UBigNumber` to `0`, without changing the array size
     */
    mutating func zero() {
        for i in 0..<words.count {
            words[i] = 0
        }
    }
    
}