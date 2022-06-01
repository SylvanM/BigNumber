//
//  File.swift
//  
//
//  Created by Sylvan Martin on 5/31/22.
//

import Foundation

public extension BigNumber {
    
    // MARK: Comparisons
    
    func equals(_ other: BigNumber) -> Bool {
        
        if self.sign != other.sign {
            return false
        }
        
        return self.magnitude.equals(other.magnitude)
        
    }
    
    /**
     * Compares this `BN` to a `BinaryInteger`, returning an `Int` representing their relation
     *
     * - Parameters:
     *      - other: `BN` to compare
     *
     * - Returns: a positive integer if `self` is greater than `other`, a negative integer if `self` is less than `other`, and `0` if `self` is equal to `other`
     */
    func compare <T: BinaryInteger> (to other: T) -> Int {
        
        let signComparison = self.sign - Int(other.signum())
        
        if signComparison != 0 {
            return signComparison
        }
        
        let magnitudeComparison = magnitude.compare(to: other.magnitude)
        
        return sign * magnitudeComparison
        
    }
    
    // MARK: Bitwise Operations
    
    /**
     * OR's every word of this `BigNumber` with the respective word of another `BigNumber`
     *
     * - Parameters:
     *      - other: another `BinaryInteger` to OR with this one
     */
    @discardableResult mutating func or <T: BinaryInteger> (with other: T) -> BigNumber {
        magnitude.or(with: other)
        return self
    }
    
    /**
     * AND's every word of this `UBigNumber` with the corresponding word of another `UBigNumber`
     *
     * - Parameters:
     *      - other: another `UBigNumber` to AND with this one
     */
    @discardableResult mutating func and <T: BinaryInteger> (with other: T) -> BigNumber {
        magnitude.and(with: other)
        return self
    }
    
    /**
     * XOR's every word of this `UBigNumber` with the corresponding word of another `UBigNumber`
     *
     * - Parameters:
     *      - other: another `UBigNumber` to XOR with this one
     */
    @discardableResult mutating func xor <T: BinaryInteger> (with other: T) -> BigNumber {
        magnitude.xor(with: other)
        return self
    }
    
    /**
     * Left shifts this `BigNumber` by some integeral amount
     *
     * - Parameters:
     *      - shift: Amount by which to left shift this `UBigNumber`
     */
    @discardableResult mutating func leftShift <T: BinaryInteger> (by shift: T) -> BigNumber {
        magnitude.leftShift(by: shift)
        return self
    }
    
    /**
     * Right shifts this `BigNumber` by some integeral amount
     *
     * - Parameters:
     *   - shift: Amount by which to left shift this `BigNumber`
     */
    @discardableResult mutating func rightShift <T: BinaryInteger> (by shift: T) -> BigNumber {
        magnitude.rightShift(by: shift)
        return self
    }
    
    // MARK: Arithmetic Operations
    
    /**
     * Adds another `BinaryInteger` to this `UBigNumber`
     *
     * - Parameters:
     *   - other: A `BinaryInteger` to add to this `UBigNumber`
     *   - handleOverflow: if `true`, this operation will append any necessary words to this `UBigNumber`
     *
     * - Returns: Sum of `self` and `other`
     */
    @discardableResult mutating func add <T: BinaryInteger> (_ other: T, withOverflowHandling handleOverflow: Bool = true) -> BigNumber {
        var otherBN = BN(other)
        
        if self.sign == otherBN.sign {
            return self.add(otherBN)
        }
        
        if self.sign == 0 {
            self = otherBN
        }
        
        if self.sign == 1 {
            return self.subtract(otherBN.negative)
        }
        
        // sign is -1
        self = otherBN.subtract(self.negative)
        return self
        
    }
    
    @discardableResult
    mutating func modadd(_ other: BigNumber, m: BigNumber) -> BigNumber{
        self %= m
        self.add(other % m)
        self %= m
        return self
    }
    
    /// Subtracts a numerical value from this `UBN`
    /// - Parameter other: `BinaryInteger` to subtract
    /// - Returns: difference of `self` and `other`
    @discardableResult mutating func subtract <T: BinaryInteger> (_ other: T) -> BigNumber {
        
        var otherBN = BN(other)
        
        if self.sign == 0 {
            self = otherBN.negative
        }
        
        if self.sign == -1 {
            
            if otherBN.sign == -1 {
                var neg = otherBN.negative
                self = neg.subtract(self.negative)
                return self
            }
            
            // other sign is 1
            self.magnitude.add(otherBN.magnitude)
            return self
            
        }
        
        // sign is 1
        if otherBN.sign == -1 {
            self.magnitude.add(otherBN.magnitude)
            return self
        }
        
        if self.magnitude == other.magnitude {
            return 0
        }
        
        if self.magnitude > other.magnitude {
            self.magnitude.subtract(other.magnitude)
            return self
        }
        
        self.magnitude = otherBN.magnitude.subtract(self.magnitude)
        self.sign = -1
        return self
        
    }
    
    @discardableResult
    mutating func modsub(_ other: BigNumber, m: BigNumber) -> BigNumber {
        self %= m
        self.subtract(other % m)
        self %= m
        return self
    }
    
    /**
     * Multiplies `x` by another `y` and stores the result in `result`
     *
     * - Parameters:
     *      - x: `BinaryInteger` to multiply
     *      - y: `BinaryInteger` to multiply by
     *      - result: `UBigNumber` to store product of `x` and `y`
     *      - handleOverflow: if `true`, this operation will append any necessary words to this `UBigNumber`
     */
    static func multiply <T: BinaryInteger> (x: T, y: T, result: inout BigNumber) {
        
        if x.signum() == y.signum() {
            result.sign = 1
        }
        
        result.sign = -1
        
        UBN.multiply(x: x.magnitude, y: y.magnitude, result: &result.magnitude)
        
    }
    
    static func modmul(x: BigNumber, y: BigNumber, m: BigNumber, result: inout BigNumber) {
        BN.multiply(x: x % m, y: y % m, result: &result)
        result %= m
    }
    
    /**
     * Divides `dividend` by `divisor`, and stores the quotient and remainder in given objects
     *
     * - Parameters:
     *      - dividend: `BinaryInteger` dividend
     *      - divisor: `BinaryInteger`
     *      - quotient: `UBigNumber` object that stores the quotient
     *      - remainder: `UBigNumber` object that stores the remainder
     */
    static func divide <T: BinaryInteger> (dividend: T, divisor: T, quotient: inout BigNumber, remainder: inout BigNumber) {
        
        if dividend.signum() == divisor.signum() {
            quotient.sign = 1
        }
        
        quotient.sign = -1
        remainder.sign = 1
        
        UBN.divide(dividend: dividend, divisor: divisor, quotient: &quotient.magnitude, remainder: &remainder.magnitude)
        
    }
    
    func moddiv(by other: BigNumber, m: BigNumber) -> BigNumber {
        BN(UBN(self).moddiv(by: UBN(other), m: UBN(m)))
    }
    
    
}
