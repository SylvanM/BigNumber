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
    func compare (to other: BigNumber) -> Int {
        
        if self.sign != other.sign {
            return sign - other.sign
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
    @discardableResult mutating func or (with other: BigNumber) -> BigNumber {
        magnitude.or(with: other)
        return self
    }
    
    /**
     * AND's every word of this `UBigNumber` with the corresponding word of another `UBigNumber`
     *
     * - Parameters:
     *      - other: another `UBigNumber` to AND with this one
     */
    @discardableResult mutating func and (with other: BigNumber) -> BigNumber {
        magnitude.and(with: other)
        return self
    }
    
    /**
     * XOR's every word of this `UBigNumber` with the corresponding word of another `UBigNumber`
     *
     * - Parameters:
     *      - other: another `UBigNumber` to XOR with this one
     */
    @discardableResult mutating func xor (with other: BigNumber) -> BigNumber {
        magnitude.xor(with: other)
        return self
    }
    
    /**
     * Left shifts this `BigNumber` by some integeral amount
     *
     * - Parameters:
     *      - shift: Amount by which to left shift this `UBigNumber`
     */
    @discardableResult mutating func leftShift (by shift: BigNumber) -> BigNumber {
        magnitude.leftShift(by: shift)
        return self
    }
    
    /**
     * Right shifts this `BigNumber` by some integeral amount
     *
     * - Parameters:
     *   - shift: Amount by which to left shift this `BigNumber`
     */
    @discardableResult mutating func rightShift (by shift: BigNumber) -> BigNumber {
        magnitude.rightShift(by: shift)
        return self
    }
    
    // MARK: Arithmetic Operations
    
    /**
     * Adds another `BinaryInteger` to this `BigNumber`
     *
     * - Parameters:
     *   - other: A `BinaryInteger` to add to this `BigNumber`
     *   - handleOverflow: if `true`, this operation will append any necessary words to this `BigNumber`
     *
     * - Returns: Sum of `self` and `other`
     */
    @discardableResult mutating func add (_ other: BigNumber, withOverflowHandling handleOverflow: Bool = true) -> BigNumber {
        
        if self.sign == other.sign {
            self.magnitude.add(other.magnitude)
            return self
        }
        
        if self.sign == 0 {
            self = other
            return self
        }
        
        if self.sign == 1 { // at this point, the other number must be negative
            return self.subtract(other.negative)
        }
        
        // if this number is negative and the other is positive...
        
        let negSelf = self.negative
        
        self.magnitude = other.magnitude
        self.sign = other.sign
        
        self.subtract(negSelf)
        
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
    @discardableResult mutating func subtract (_ other: BigNumber) -> BigNumber {
        
        if other.sign == -1 {
            return self.add(other.negative)
        }
        
        // now we assume we are subtracting a positive integer
        
        if self.sign == 0 {
            self.magnitude = other.magnitude
            self.sign = -1
            return self
        }
        
        if self.sign == 1 {
            // the difference of two positive numbers! Swell!
            
            if self.magnitude > other.magnitude {
                self.magnitude.subtract(other.magnitude)
                return self
            } else if self.magnitude < other.magnitude {
                self.magnitude = other.magnitude - self.magnitude
                self.sign = -1
                return self
            } else {
                self = 0
                return self
            }
        }
        
        // self is a negative number, so we are looking at a negative number minus a positive number
        self.magnitude.add(other.magnitude)
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
    static func multiply (x: BigNumber, y: BigNumber, result: inout BigNumber) {
        
        if x.sign == y.sign {
            result.sign = 1
        } else {
            result.sign = -1
        }
            
        UBN.multiply(x: x.magnitude, y: y.magnitude, result: &result.magnitude)
        
        result.normalize()
        
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
    static func divide (dividend: BigNumber, divisor: BigNumber, quotient: inout BigNumber, remainder: inout BigNumber) {
        
        if dividend.signum() == divisor.signum() {
            quotient.sign = 1
        } else {
            quotient.sign = -1
        }
        
        remainder.sign = dividend.sign
        
        UBN.divide(dividend: dividend.magnitude, divisor: divisor.magnitude, quotient: &quotient.magnitude, remainder: &remainder.magnitude)
        
        quotient.normalize()
        remainder.normalize()
        
    }
    
    /**
     * Performs modular division by `other` modulo `m`
     */
    func moddiv(by other: BigNumber, m: BigNumber) -> BigNumber {
        BN(UBN(self).moddiv(by: UBN(other), m: UBN(m)))
    }
    
    /**
     * Returns `self` raised to the power of `power`, where `power` is a non-negative integer
     *
     * - Invariant: `power >= 0`
     */
    func pow(_ power: BigNumber) -> BigNumber {
        BigNumber(
            sign: power.isEven ? sign * sign : sign,
            magnitude: self.magnitude.pow(power.magnitude)
        )
    }
    
}
