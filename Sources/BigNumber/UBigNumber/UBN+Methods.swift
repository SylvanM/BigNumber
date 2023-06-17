//
//  File.swift
//  
//
//  Created by Sylvan Martin on 2/20/20.
//

import Foundation

public extension UBigNumber {
    
    // MARK: Modulo Methods
    
    /**
     * Computes `x` such that `x * self = 1 (mod m)` or returns garbage if `x` is not relatively prime to `m`
     *
     * - Parameters:
     *      - m: Modulo for the inverse modulo
     *
     * - Returns: `x` such that `x * self = 1 (mod m)` or garbage if `x` is not relatively prime to `m`
     */
    func invMod(_ m: UBigNumber) -> UBigNumber {
        BN(sign: 1, magnitude: self).invMod((BN(m))).magnitude
    }
    
    // MARK: Modular Exponentiation (Non-operator definitions)
        
    /**
     * Quickly computes A^B mod C
     *
     * - Parameters:
     *      - a: Base
     *      - b: Exponent
     *      - m: Modulo
     *      - invPower: `Bool` indicating whether the exponent `b` should be treated as a negative exponent even though it is unsigned
     *
     * - Returns: ```a ^ b mod c```
     */
    static func modPow(a: UBigNumber, b: UBigNumber, m: UBigNumber, invPower: Bool = false) -> UBigNumber {
        BN.modPow(a: BN(a), b: BN(b), m: BN(sign: invPower ? -1 : 1, magnitude: m)).magnitude
    }
    
    // MARK: - GCD Algorithms
    
    /**
     * Returns the greatest common denominator of two `UBigNumber`s including this one
     *
     * - Parameters:
     *      - b: Another `UBN`
     *
     * - Returns: `gcd(self, b)`
     */
    static func gcd(_ a: UBigNumber, _ b: UBigNumber) -> UBigNumber {
        genericGcd(a: a, b: b)
    }
    
    // MARK: Primality Tests
    
    /**
     * Fermat Primality Test
     *
     * Checks if a number is a probable prime using Fermat's Little Theorem, stating that if `n` is a prime, then
     * `a(n-1) = 1 (mod n)` for all `1 < a < p`
     *
     * If `n` is not prine, then (except for Charmichael numbers) approximately 1/2 of the integers `a` will
     * return a value not equal to 1 when raised to the `(n - 1)` modulo `n`, so this function tries
     * 128 random numers. If all of them work, then `n` is a prime with a probability of `1 - 2^(-128)`. If any fail, this is most
     * certainly not a prime.
     *
     * - Parameters:
     *      - n: Number of which to test the primality
     *
     * - Returns: `true` if `n` is a probable prime
     */
    func isProbablePrime() -> Bool {
        
        if self == 1 {
            return false
        }
        
        // Quick check to make sure this number isn't divisible by any of the usual suspects
        let smallPrimes: [UBN] = [
            2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31
        ]
        
        var m: UBN = 1
        
        for prime in smallPrimes {
            if self == prime {
                return true
            }
            m *= prime
        }
        
        if UBN.gcd(self, m) != 1 {
            return false
        }
        
        for _ in 0..<128 {
            
            var rand: UBN
            
            repeat {
                rand = UBN.random(words: size)
            } while rand == self
                        
            
            if UBN.modPow(a: rand, b: rand-1, m: self) != 1 {
                return false
            }
            
        }
        
        return true
        
    }
    
    /**
     * Generates a prime of a given bit size
     *
     * Usually the call to any random number generator must be random, but luckily Swift handles
     * all that stuff for us!
     *
     * Approximate Run Times:
     *
     *       bitsize   time
     *      --------- -------
     *           64   0.5 sec
     *          128     3 sec
     *          256    30 sec
     *          512     5 min
     *         1024    30 min
     *
     * - Parameters:
     *      - bytes: `Int` representing number of bytes for this new prime `UBN`
     *
     * - Returns: Probable prime with `bytes` bytes
     */
    static func generateProbablePrime(bytes: Int) -> UBigNumber {
        
        var prime = UBN(secureRandomBytes: bytes)
        while (!prime.isProbablePrime()) {
            prime = UBN(secureRandomBytes: bytes)
        }
        return prime
    }
    
}
