//
//  File.swift
//  
//
//  Created by Sylvan Martin on 5/7/20.
//

import Foundation

extension BigNumber: Comparable, Equatable {
    
    // MARK: - Comparative Operators
    
    /**
     * Checks if two `BigNumber`s are equal
     *
     * - Parameters:
     *      - lhs: `BigNumber` to compare
     *      - rhs: `BigNumber` to compare
     *
     * - Returns: `true` if `lhs` and `rhs` are numerically equivalent, `false` if not.
     */
    public static func == (lhs: BigNumber, rhs: BigNumber) -> Bool {
        lhs.equals(rhs)
    }
    
    /**
     * Checks if two `BigNumber`s are unequal
     *
     * - Parameters:
     *      - lhs: `BigNumber` to compare
     *      - rhs: `BigNumber` to compare
     *
     * - Returns: `true` if `lhs` and `rhs` are not numerically equivalent, `false` if they are.
     */
    public static func != (lhs: BigNumber, rhs: BigNumber) -> Bool {
        !lhs.equals(rhs)
    }
    
    /**
     * Checks if two one `BigNumber` is greater than another
     *
     * - Parameters:
     *      - lhs: `BigNumber` to compare
     *      - rhs: `BigNumber` to compare
     *
     * - Returns: `true` if `lhs` is numerically greater than `rhs`. `false` if otherwise.
     */
    public static func > (lhs: BigNumber, rhs: BigNumber) -> Bool {
        lhs.compare(to: rhs) > 0
    }
    
    /**
     * Checks if two one `BigNumber` is less than another
     *
     * - Parameters:
     *      - lhs: `BigNumber` to compare
     *      - rhs: `BigNumber` to compare
     *
     * - Returns: `true` if `lhs` is numerically less than `rhs`. `false` if otherwise.
     */
    public static func < (lhs: BigNumber, rhs: BigNumber) -> Bool {
        lhs.compare(to: rhs) < 0
    }
    
    /**
     * Checks if two one `BigNumber` is greater than or equal to another
     *
     * - Parameters:
     *      - lhs: `BigNumber` to compare
     *      - rhs: `BigNumber` to compare
     *
     * - Returns: `true` if `lhs` is numerically greater than or equal to `rhs`. `false` if otherwise.
     */
    public static func >= (lhs: BigNumber, rhs: BigNumber) -> Bool {
        lhs.compare(to: rhs) >= 0
    }
    
    /**
     * Checks if two one `BigNumber` is less than or equal to another
     *
     * - Parameters:
     *      - lhs: `BigNumber` to compare
     *      - rhs: `BigNumber` to compare
     *
     * - Returns: `true` if `lhs` is numerically less than or equal to `rhs`. `false` if otherwise.
     */
    public static func <= (lhs: BigNumber, rhs: BigNumber) -> Bool {
        lhs.compare(to: rhs) <= 0
    }
    
    // MARK: Range Operators
    
    /**
     * Returns an inclusive range of values between two `BigNumber`
     *
     * - Parameters:
     *      - lhs: Lower bound
     *      - rhs: Upper bound
     *
     * - Returns: A range of values between `lhs` and `rhs`, including both bounds: `[lhs, rhs]`
     */
    public static func ... <RHS: BinaryInteger> (lhs: BigNumber, rhs: RHS) -> ClosedRange<BigNumber> {
        ClosedRange<BigNumber>(uncheckedBounds: (lower: lhs, upper: BN(truncatingIfNeeded: rhs)))
    }
    
    /**
     * Returns a range of values between two `BigNumber`, excluding the upper bound
     *
     * - Parameters:
     *      - lhs: Lower bound
     *      - rhs: Upper bound
     *
     * - Returns: A range of values between `lhs` and `rhs`, including both bounds:`[lhs, rhs)`
     */
    public static func ..< <RHS: BinaryInteger> (lhs: BigNumber, rhs: RHS) -> Range<BigNumber> {
        Range<BigNumber>(uncheckedBounds: (lower: lhs, upper: BN(truncatingIfNeeded: rhs)))
    }
    
    // MARK: - Bitwise Operators
    
    /**
     * Stores the result of performing a bitwise `OR` operation on the two given
     * values in the left-hand-side variable.
     *
     * A bitwise AND operation results in a value that has each bit set to `1`
     * where *one* of its arguments have that bit set to `1`.
     *
     * - Parameters:
     *      - lhs: A `BigNumber` value
     *      - rhs: A `BinaryInteger` value
     */
    public static func |= <RHS> (lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.or(with: rhs)
    }
    
    /**
     * Stores the result of performing a bitwise `AND` operation on the two given
     * values in the left-hand-side variable.
     *
     * A bitwise AND operation results in a value that has each bit set to `1`
     * where *both* of its arguments have that bit set to `1`.
     *
     * - Parameters:
     *      - lhs: A `BigNumber` value
     *      - rhs: A `BinaryInteger` value
     */
    public static func &= <RHS> (lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.and(with: rhs)
    }
    
    /**
     * Stores the result of performing a bitwise `XOR` operation on the two given
     * values in the left-hand-side variable.
     *
     * A bitwise AND operation results in a value that has each bit set to `1`
     * where *one and only one* of its arguments have that bit set to `1`.
     *
     * - Parameters:
     *      - lhs: A `BigNumber` value
     *      - rhs: A `BinaryInteger` value
     */
    public static func ^= <RHS> (lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.xor(with: rhs)
    }
    
    /**
     * Left bitshifts a value by another, and stores the result in the left-hand-side variable, with no overflow handling.
     *
     * - Parameters:
     *      - lhs: value to left bitshift
     *      - rhs: `BinaryInteger` amount to bitshift
     */
    public static func &<<= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.leftShift(by: rhs, withOverflowHandling: false)
    }
    
    /**
     * Left bitshifts a value by another, and stores the result in the left-hand-side variable
     *
     * - Parameters:
     *      - lhs: value to left bitshift
     *      - rhs: `BinaryInteger` amount to bitshift
     */
    public static func <<= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.leftShift(by: rhs)
    }
    
    /**
     * Right bitshifts a `BigNumber` value by another `BinaryInteger` and stores the result in the left-hand-side
     *
     * - Parameters:
     *      - lhs: value to right-shift
     *      - rhs: `BinaryInteger` amount to shift
     */
    public static func >>= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.rightShift(by: rhs)
    }
    
    /**
     * The binary compliment of a `BigNumber`
     *
     * - Parameters:
     *      - bn: The `BigNumber` of which to get the compliment
     *
     * - Returns: The binary compliment of `bn`
     */
    public static prefix func ~ (bn: BigNumber) -> BigNumber {
        bn.binaryCompliment
    }
    
    /**
     * Bitwise `OR` operator
     *
     * - Parameters:
     *      - lhs: `BigNumber` to `OR`
     *      - rhs: `BigNumber` to `OR`
     *
     * - Returns: The bitwise `OR` of the two `BigNumber`s
     */
    public static func | <RHS> (lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.or(with: rhs)
    }
    
    /**
     * Bitwise `AND` operator
     *
     * - Parameters:
     *      - lhs: `BigNumber` to `AND`
     *      - rhs: `BigNumber` to `AND`
     *
     * - Returns: The bitwise `AND` of the two `BigNumber`s
     */
    public static func & <RHS> (lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.and(with: rhs)
    }
    
    /**
     * Bitwise `XOR` operator
     *
     * - Parameters:
     *      - lhs: `BigNumber` to `XOR`
     *      - rhs: `BigNumber` to `XOR`
     *
     * - Returns: The bitwise `XOR` of the two `BigNumber`s
     */
    public static func ^ <RHS> (lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.xor(with: rhs)
    }
    
    /**
     * Bitwise left shift operator with no overflow handling
     *
     * - Parameters:
     *      - lhs: `BigNumber` to shift
     *      - rhs: `BinaryInteger` amount to shift
     *
     * - Returns: Result of the bitwise left shift operation, with no overflow handling
     */
    public static func &<< <RHS> (lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.leftShift(by: rhs, withOverflowHandling: false)
    }
    
    /**
     * Bitwise left shift operator
     *
     * - Parameters:
     *      - lhs: `BigNumber` to shift
     *      - rhs: `BinaryInteger` amount to shift
     *
     * - Returns: Result of the bitwise left shift operation
     */
    public static func << <RHS> (lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.leftShift(by: rhs)
    }
    
    /**
     * Bitwise right shift operator
     *
     * - Parameters:
     *      - lhs: `BigNumber` to shift
     *      - rhs: `BinaryInteger` amount to shift
     *
     * - Returns: Result of the bitwise right shift operation
     */
    public static func >> <RHS> (lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.rightShift(by: rhs)
    }
    
    // MARK: Arithmetic Operators
    
    /**
     * Adds two `BigNumber`s and stores the sum in the left-hand-side variable
     *
     * - Parameters:
     *      - lhs: `BigNumber` to increment
     *      - rhs: `BigNumber` to add to `rhs`
     */
    public static func += (lhs: inout BigNumber, rhs: BigNumber) {
        lhs.add(rhs)
    }
    
    /**
     * Subtracts a `BigNumber` from another and stores the result in the left-hand-side variable
     *
     * - Parameters:
     *      - lhs: `BigNumber` to increment
     *      - rhs: `BigNumber` to subtract from `rhs`
     */
    public static func -= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs.subtract(rhs)
    }
    
    /**
     * Multiplication assignment operator
     *
     * - Parameters:
     *      - lhs: `BigNumber` multiplicand
     *      - rhs: `BigNumber` multiplier
     */
    public static func *= (lhs: inout BigNumber, rhs: BigNumber) {
        multiply(x: lhs, by: rhs, result: &lhs)
    }
    
    /**
     * Division assignment operator
     *
     * - Parameters:
     *      - lhs: dividend and `BN` to store result of operation
     *      - rhs: divisor
     */
    public static func /= <RHS> (lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        var r = BN()
        divide(dividend: lhs, divisor: BigNumber(truncatingIfNeeded: rhs), quotient: &lhs, remainder: &r)
    }
    
    /**
     * Remainder assignment operator
     *
     * - Parameters:
     *      - dividend: `BigNumber` to divide I guess
     *      - modulus: Not sure what to write here
     */
    public static func %= (lhs: inout BigNumber, rhs: BigNumber) {
        var q = BN()
        divide(dividend: lhs, divisor: rhs, quotient: &q, remainder: &lhs)
    }
    
    // MARK: Non-Assignment Arithmetic Operators
    
    /**
     * The sum of two `BigNumber`s
     *
     * - Parameters:
     *      - lhs: `BigNumber` to add
     *      - rhs: `BigNumber` to add
     *
     * - Returns: The sum of `lhs` and `rhs`
     */
    public static func + (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var a = lhs
        return a.add(rhs)
    }
    
    /**
     * The difference of two `BigNumber`s
     *
     * - Parameters:
     *      - lhs: `BigNumber`
     *      - rhs: `BigNumber` to subtract
     *
     * - Returns: The sum of `lhs` and `rhs`
     */
    public static func - (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var a = lhs
        return a.subtract(rhs)
    }
    
    /**
     * The product of two `BigNumber`s
     *
     * - Parameters:
     *      - lhs: A `BigNumber` to multiply
     *      - rhs: A `BigNumber` to multiply
     *
     * - Returns: Product of `lhs` and `rhs`
     */
    public static func * (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var p = BN()
        multiply(x: lhs, by: rhs, result: &p)
        return p
    }
    
    /**
     * The quotient of two `BigNumber`s
     *
     * - Parameters:
     *      - lhs: A `BigNumber` dividend
     *      - rhs: A `BigNumber` divisor
     *
     * - Returns: quotient of `lhs` and `rhs`
     */
    public static func / (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var q = BN()
        var r = BN()
        divide(dividend: lhs, divisor: rhs, quotient: &q, remainder: &r)
        return q
    }
    
    /**
     * Modulo operator
     *
     * I've run out of documentation enery for today
     */
    public static func % (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var a = lhs
        a %= rhs
        return a
    }
    
    // MARK: Modular Exponentiation
    
    public static func **(base: BigNumber, power: BigNumber) -> (base: BigNumber, power: BigNumber) {
        (base: base, power: power)
    }
    
    public static func %(lhs: (base: BigNumber, power: BigNumber), rhs: BigNumber) -> BigNumber {
        return modExp(a: lhs.base, b: lhs.power, m: rhs)
    }
    
}
