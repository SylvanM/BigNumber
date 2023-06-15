//
//  File.swift
//  
//
//  Created by Sylvan Martin on 5/31/22.
//

import Foundation

public extension BigNumber {
    
    // MARK: Utility Methods
    
    /**
     * Gets rid of extraneous leading zeroes
     *
     * - Returns: The normalized version of this `UBigNumber`
     */
    @discardableResult mutating func normalize() -> BigNumber {
        
        if self.magnitude.isZero {
            self.sign = 0
        }
        
        self.magnitude.normalize()
    
        return self
            
    }
    
    /// Hashes the ```UBigNumber```
    func hash(into hasher: inout Hasher) {
        for element in words {
            hasher.combine(element)
        }
        hasher.combine(sign)
    }
    
    /**
     * Generates a random `UBN`
     *
     * - Parameters:
     *      - size: The maximum number of words in the random `UBN` to be generated
     *
     * - Returns: A `UBN` with a random value
     */
    static func random(words: Int, generator: SecRandomRef? = kSecRandomDefault) -> BigNumber {
        
        let randomMag = UBN.random(words: words, generator: generator)
        var randomSign = [0]
        
        if randomMag.isZero {
            return BN(sign: randomSign[0], magnitude: randomMag)
        }
        
        // randomize the sign
        _ = SecRandomCopyBytes(generator, 1, &randomSign)
        
        randomSign[0] %= 2
        randomSign[0] *= 2
        randomSign[0] -= 1
        
        var random = BN()
        
        random.sign = randomSign[0]
        random.magnitude = randomMag
        
        return random
        
    }
    
    /**
     * Generates a random `UBN`
     *
     * - Parameters:
     *      - bytes: The maximum number of bytes in the random `UBN` to be generated
     *
     * - Returns: A `UBN` with a random value
     */
    static func random(bytes: Int, generator: SecRandomRef? = kSecRandomDefault) -> BigNumber {
        
        let randomMag = UBN.random(bytes: bytes, generator: generator)
        var randomSign = [0]
        
        if randomMag.isZero {
            return BN(sign: randomSign[0], magnitude: randomMag)
        }
        
        // randomize the sign
        _ = SecRandomCopyBytes(generator, 1, &randomSign)
        
        randomSign[0] %= 2
        randomSign[0] *= 2
        randomSign[0] -= 1
        
        var random = BN()
        
        random.sign = randomSign[0]
        random.magnitude = randomMag
        
        return random
        
    }
    
    @discardableResult
    mutating func setToZero() -> BigNumber {
        self.sign = 0
        self.magnitude.setToZero()
        return self
    }
    
    func signum() -> BigNumber {
        BN(sign)
    }
    
    @discardableResult
    mutating func set(sign: Int) -> BigNumber {
        
        if sign < 0 {
            self.sign = -1
        } else if sign > 0 {
            self.sign = 1
        } else {
            self.sign = 0
            self.setToZero()
        }
        
        return self
        
    }
    
}
