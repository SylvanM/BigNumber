//
//  File.swift
//  
//
//  Created by Sylvan Martin on 5/31/22.
//

import Foundation

public extension BigNumber {
    
    // MARK: Modulo Methods
    
    @discardableResult
    static func extgcd(a: BigNumber, b: BigNumber, x: inout BigNumber, y: inout BigNumber) -> BigNumber {
        
        x = 0
        y = 0
        
        if a == 0 {
            
            assert(!b.isZero, "gcd(0, 0) is undefined")
            
            y = 1
            
            y.sign = b.sign
            return b
        }
        
        if b.isZero {
            x = 1
            x.sign = a.sign
            return a
        }
        
        var xp: BN = 0
        var yp: BN = 0
        
        var q = BN()
        var r = BN()
        
        BN.divide(dividend: a, divisor: b, quotient: &q, remainder: &r)
     
        let gcd = extgcd(a: b, b: r, x: &xp, y: &yp)
     
        y = xp - (yp * q)
        x = yp
     
        return gcd
        
    }
    
    /**
     * Computes `x` such that `x * self = 1 (mod m)` or returns garbage if `x` is not relatively prime to `m`
     *
     * - Parameters:
     *      - m: Modulo for the inverse modulo
     *
     * - Returns: `x` such that `x * self = 1 (mod m)` or garbage if `x` is not relatively prime to `m`
     */
    func invMod(_ m: BigNumber) -> BigNumber {

        var x: BigNumber = 0
        var y: BigNumber = 0

        BigNumber.extgcd(a: self, b: m, x: &x, y: &y)

        return x

    }
    
    // MARK: Modular Exponentiation (Non-operator definitions)
        
    /**
     * Quickly computes A^B mod C
     *
     * - Parameters:
     *      - a: Base
     *      - b: Exponent
     *      - m: Modulo
     *
     * - Returns: ```a ^ b mod c```
     */
    static func modexp(a: BigNumber, b: BigNumber, m: BigNumber) -> BigNumber {
        
        let bitSize = b.bitWidth
        var t: BN = a
        var x: BN = 1
        
        if m.sign == -1 {
            t = a.invMod(-m)
        }
        
        for i in (1...bitSize).reversed() {
            let xm = x % m
            x = (xm * xm) % m
            if b[bit: i-1] == 1 {
                x = (xm * (t % m)) % m
            }
        }
        
        return x
        
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
    func gcd(_ b: BigNumber) -> BigNumber {
        
        if self == 0 {
            if b == 0 {
                fatalError("gcd(0, 0) is undefined")
            }
            return b
        }
        
        if b == 0 {
            return self
        }
        
        if self == 0 || b == 0 {
            return 1
        }
        
        return b.gcd(self % b)
        
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
        
        if sign == -1 {
            return false
        }
        
        return magnitude.isProbablePrime()
        
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
    static func generateProbablePrime(bytes: Int) -> BigNumber {
        BN(UBigNumber.generateProbablePrime(bytes: bytes))
    }
    
}
