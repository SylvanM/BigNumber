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
     * Generates a random `UBN` with a certain amount of random bits
     */
    static func random(bits: Int, generator: SecRandomRef? = kSecRandomDefault) -> UBigNumber {
        var randomValue: UBN = .zero
        
        let (wordsToGenerate, bitsAndBytes) = bits.quotientAndRemainder(dividingBy: 64)
        let (bytesToGenerate, bitsToGenerate) = bitsAndBytes.quotientAndRemainder(dividingBy: 8)
        
        randomValue = random(words: wordsToGenerate)
        
        randomValue <<= 8 * bytesToGenerate
        randomValue |= random(bytes: bytesToGenerate)
        
        randomValue <<= bitsToGenerate
        randomValue |= random(bytes: 1) & ((1 << bitsToGenerate) - 1)
        
        return randomValue
    }
    
    /**
     * Generates a random `UBN`
     *
     * - Parameters:
     *      - bytes: The maximum number of bytes in the random `UBN` to be generated
     *
     * - Returns: A `UBN` with a random value
     */
    static func random(bytes: Int, generator: SecRandomRef? = kSecRandomDefault) -> UBigNumber {
        let source = random(words: (bytes / WordType.size) + 1, generator: generator)
        let mask = (UBN(1) << UBN(bytes * 8)) - 1
        return source & mask
    }
    
    /**
     * Generates a random `UBN`
     *
     * - Parameters:
     *      - words: The maximum number of words in the random `UBN` to be generated
     *
     * - Returns: A `UBN` with a random value
     */
    static func random(words: Int, generator: SecRandomRef? = kSecRandomDefault) -> UBigNumber {
        let words = [WordType](repeating: 0, count: words)
        var a = UBN()
        a.words = words
        _ = SecRandomCopyBytes(generator, a.sizeInBytes, &a.words)
        return a.normalize()
    }
    
    /**
     * Generates a uniformly random `UBN` in a range
     *
     * - Parameter range: The range in which the `UBigNumber` should be generated
     *
     * - Returns: A `UBN` in `range`
     */
    static func random(`in` range: Range<UBigNumber>) -> UBigNumber {
        // generate the amount of randomness needed, then shift that randomness to be in the range
        
        if range.lowerBound == 0 {
            // how many bits are needed to represent this guy?
            let bitsNeeded = range.upperBound.mostSignificantSetBitIndex + 1
            var randomValue: UBN = 0
            
            repeat {
                randomValue = random(bits: bitsNeeded)
            } while !range.contains(randomValue)
            
            return randomValue
            
        } else {
            return range.lowerBound + random(
                in: Range(uncheckedBounds: (
                    lower: .zero,
                    upper: range.upperBound - range.lowerBound
                ))
            )
        }
    }
    
    @discardableResult
    mutating func setToZero() -> UBigNumber {
        self.words = [0]
        return self
    }
    
}
