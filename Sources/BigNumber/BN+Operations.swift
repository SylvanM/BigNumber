//
//  File.swift
//  
//
//  Created by Sylvan Martin on 5/7/20.
//

import Foundation

public extension BigNumber {
    
    // MARK: - Comparison
    
    /**
     * Checks if another `BN` equals this one
     *
     * - Parameters:
     *      - other: `BN` to compare
     *
     * - Returns: `true` if the numbers are numerically equal
     */
    func equals(_ other: BN) -> Bool {
        
        var thisHash  = Hasher()
        var otherHash = Hasher()
        
        self.hash(into: &thisHash)
        other.hash(into: &otherHash)
        
        // should I not hash the signs and instead compare them separately?
        
        #warning("Speed test this, testing the other way of comparing equivalence")
        // like jhust compare the magnitudes and signs separately
        
        return thisHash.finalize() == otherHash.finalize()
        
    }
    
    /**
     * Compares this `BN` to another, returning an `Int` representing their relation
     *
     * - Parameters:
     *      - other: `BN` to compare
     *
     * - Returns: a positive integer if `self` is greater than `other`, a negative integer if `self` is less than `other`, and `0` if `self` is equal to `other`
     */
    func compare(to other: BN) -> Int {
        
        // try to get the fast operations out of the way first
        
        if self.sign != other.sign {
            return self.sign - other.sign
        }
        
        // signs are equal, so now just compare magnitudes
        
        let comparison = compare(to: other)
        
        return comparison == 0 ? 0 : (
            self.sign == -1 ? -comparison : comparison
        )
        
    }
    
    // MARK: - Bitwise Operations
    
    /**
     * `OR`s every bit of this `BigNumber` with the respective bit of another `BigNumber`
     *
     * - Parameters:
     *      - other: another `BinaryInteger` to `OR` with this one
     *
     * - Returns: The result of the bitwise `OR` operation
     */
    @discardableResult mutating func or <T: BinaryInteger> (with other: T) -> BigNumber {
        self.magnitude.or(with: other.magnitude)
        self.sign = self.isZero ? 0 : 1
        return self
    }
    
    /**
     * `AND`s every bit of this `BigNumber` with the respective bit of another `BigNumber`
     *
     * - Parameters:
     *      - other: another `BinaryInteger` to `AND` with this one
     *
     * - Returns: The result of the bitwise `AND` operation
     */
    @discardableResult mutating func and <T: BinaryInteger> (with other: T) -> BigNumber {
        self.magnitude.and(with: other.magnitude)
        self.sign *= Int(other.signum())
        return self
    }
    
    /**
     * `XOR`s every bit of this `BigNumber` with the respective bit of another `BigNumber`
     *
     * - Parameters:
     *      - other: another `BinaryInteger` to `XOR` with this one
     *
     * - Returns: The result of the bitwise `XOR` operation
     */
    @discardableResult mutating func xor  <T: BinaryInteger> (with other: T) -> BigNumber {
        self.magnitude.xor(with: other.magnitude)
        self.sign = self.isZero ? 0 : 1
        return self
    }
    
    /**
     * Left shifts this `BigNumber` by some integeral amount
     *
     * - Parameters:
     *      - shift: Amount by which to left shift this `BigNumber`
     *      - handleOverflow: if `true`, this operation will append any necessary words to the words array of this `BigNumber`
     *
     * - Returns: The result of the left shift operation
     */
    @discardableResult mutating func leftShift <T: BinaryInteger> (by shift: T, withOverflowHandling handleOverflow: Bool = true) -> BigNumber {
        self.magnitude.leftShift(by: shift, withOverflowHandling: handleOverflow)
        self.sign = self.isZero ? 0 : 1
        return self
    }
    
    /**
     * Right shifts this `BigNumber` by some integeral amount
     *
     * - Parameters:
     *      - shift: Amount by which to right shift this `BigNumber`
     */
    @discardableResult mutating func rightShift <T: BinaryInteger> (by shift: T) -> BigNumber {
        self.magnitude.rightShift(by: shift)
        self.sign = self.isZero ? 0 : 1
        return self
    }
    
    // MARK: - Arithmetic Operations
    
    /**
     * Adds another `BinaryInteger` to this `BigNumber`
     *
     * - Parameters:
     *      - other: A `BinaryInteger` to add to this `BigNumber`
     *
     * - Returns: Result of the addition operation
     */
    @discardableResult mutating func add <T: BinaryInteger> (_ other: T) -> BigNumber {
        
        if self.sign == other.signum() {
            self.magnitude.add(other.magnitude)
            return self
        }
        
        let comparison = self.magnitude.compare(to: other.magnitude)
        
        if comparison == 0 {
            self.magnitude.zero()
            self.sign = 0
            return self
        }
        
        if comparison > 0 {
            self.magnitude.subtract(other.magnitude)
            return self
        }
        
        self.magnitude = UBN(other) - self.magnitude
        self.sign = -self.sign
        
        return self
        
    }
    
    /**
     * Subtracts another `BinaryInteger` from this `BigNumber`
     *
     * - Parameters:
     *      - other: A `BinaryInteger` to subtract from this `BigNumber`
     *
     * - Returns: Result of the subtraction operation
     */
    @discardableResult mutating func subtract <T: BinaryInteger> (_ other: T) -> BigNumber {
        
        if other.signum() == 0 {
            return self
        }
        
        // is this too slow?
        return self.add(other * -1)
        
    }
    
    /**
     * Multiplies `x` by another `y` and stores the result in `result`
     *
     * - Parameters:
     *      - x: `BinaryInteger` to multiply
     *      - y: `BinaryInteger` to multiply
     *      - result: `BigNumber` to store product of `x` and `y`
     */
    static func multiply <T: BinaryInteger> (x: T, by y: T, result: inout BigNumber) {
        UBigNumber.multiply(x: x.magnitude, by: y.magnitude, result: &result.magnitude)
        result.sign = Int(x.signum() * y.signum())
    }
    
    /**
     * Divides `dividend` by `divisor`, and stores the quotient and remainder in given objects
     *
     * - Parameters:
     *      - dividend: `BinaryInteger` dividend
     *      - divisor: `BinaryInteger` divisor
     *      - quotient: `BigNumber` object that stores the quotient
     *      - remainder: `BigNumber` object storing the remainder
     */
    static func divide <T: BinaryInteger> (dividend: T, divisor: T, quotient: inout BigNumber, remainder: inout BigNumber) {
        // take care of signs
        quotient.sign = dividend.signum() == divisor.signum() ? 1 : -1
        remainder.sign = Int(dividend.signum())
        
        UBigNumber.divide(dividend: dividend.magnitude, divisor: divisor.magnitude, quotient: &quotient.magnitude, remainder: &remainder.magnitude)
        
        quotient.sign  = quotient.magnitude.isZero ? 0 : quotient.sign
        remainder.sign = remainder.magnitude.isZero ? 0 : remainder.sign
    }

    
}
