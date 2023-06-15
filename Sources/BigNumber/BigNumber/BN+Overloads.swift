//
//  File.swift
//  
//
//  Created by Sylvan Martin on 5/31/22.
//

import Foundation

public extension BigNumber {
    
    // MARK: - Comparative Operators
    
    /// Compares two `BigNumbers`, returns true if they are equal
    ///
    /// - Parameters:
    ///     - lhs: `BigNumber` to compare
    ///     - rhs: Another `BigNumber` to compare
    ///
    /// - Returns: `true` if `lhs` and `rhs` are numerically equivalent, `false` if not.
    static func == (lhs: BigNumber, rhs: BigNumber) -> Bool {
        lhs.equals(rhs)
    }
    
    /// Compares two BigNumbers and retuns true if they are not equal
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to compare
    ///     - rhs: Another BigNumber to compare
    ///
    /// - Returns: True if they are equal, false if not
    static func != (lhs: BigNumber, rhs: BigNumber) -> Bool {
        !lhs.equals(rhs)
    }
    
    /// Greater than operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if lhs > rhs
    static func > (lhs: BigNumber, rhs: BigNumber) -> Bool {
        lhs.compare(to: rhs) > 0
    }
    
    /// Less than operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if lhs is less than rhs
    static func < (lhs: BigNumber, rhs: BigNumber) -> Bool {
        lhs.compare(to: rhs) < 0
    }
    
    /// Greater than or Equal to Operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if lhs >= rhs
    static func >= (lhs: BigNumber, rhs: BigNumber) -> Bool {
        lhs.compare(to: rhs) >= 0
    }
    
    /// Less than or Equal to Operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if `lhs` is less than or equal to
    static func <= (lhs: BigNumber, rhs: BigNumber) -> Bool {
        lhs.compare(to: rhs) <= 0
    }
    
    // MARK: - Range Operators
    
    /// Returns a range of all values between two values, inclusive
    ///
    /// - Parameters:
    ///     - lhs: Lower bound
    ///     - rhs: Upper bound
    ///
    /// - Returns: An range of all values between ```lhs``` and ```rhs```, inclusive
    static func ... <RHS: BinaryInteger>(lhs: BigNumber, rhs: RHS) -> ClosedRange<BigNumber> {
        ClosedRange<BigNumber>(uncheckedBounds: (lower: lhs, upper: BN(rhs)))
    }
    
    /// Returns all values between two values, excluding the upper bound
    ///
    /// - Parameters:
    ///     - a: Lower bound
    ///     - b: Upper bound
    ///
    /// - Returns: An array of all values between ```a``` and ```b```, excluding ```b```
    static func ..< <RHS: BinaryInteger>(lhs: BigNumber, rhs: RHS) -> Range<BigNumber> {
        Range<BigNumber>(uncheckedBounds: (lower: lhs, upper: BN(rhs)))
    }
    
    // MARK: - Bitwise Operators
    
    /**
     * All bitwise operators can be called with an argument of a `UBigNumber` and any other object conforming to the `BinaryInteger` protocol
     */
    
    /// Stores the result of performing a bitwise OR operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
    static func |= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.or(with: BigNumber(rhs))
    }
    
    /// Stores the result of performing a bitwise AND operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
    static func &= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.and(with: BigNumber(rhs))
    }
    
    /// Stores the result of performing a bitwise XOR operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
    static func ^= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.xor(with: BigNumber(rhs))
    }
    
    /// Left bitshifts a value by another, and stores the result in the left hand side variable
    ///
    /// - Parameters:
    ///     - a: value to left bitshift
    ///     - b: amoutnt by which to left bitshift
    static func <<= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.leftShift(by: BigNumber(rhs))
    }
    
    /// Right bitshifts a value by another, and stores the result in the left hand side variable
    /// Currently, this only actually works when bitshifting by a number smaller than 64. :(
    ///
    /// - Parameters:
    ///     - a: value to right bitshift
    ///     - b: amoutnt by which to right bitshift
    static func >>= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.rightShift(by: BigNumber(rhs))
    }
    
    /// One's compliment
    ///
    /// - Parameters:
    ///     - ubn: The `UBigNumber` to get the compliment of
    ///
    /// - Returns: The binary compliment of `ubn`
    static prefix func ~ (bn: BigNumber) -> BigNumber {
        bn.binaryCompliment
    }
    
    /// Bitwise OR operator
    ///
    /// Casts the smaller `UBigNumber` to a `UBigNumber` of the same size as the larger, and performs the bitwise `OR` operation, returning the resulting `UBigNumber`
    ///
    /// - Parameters:
    ///     - lhs: `UBigNumber` to `OR`
    ///     - rhs: `UBigNumber` to `OR`
    ///
    /// - Returns: Bitwise `OR` of the two `UBigNumbers`
    static func | <RHS>(lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.or(with: BigNumber(rhs))
    }
    
    /// Bitwise AND operator
    ///
    /// Casts the smaller BigNumber to a BigNumber of the same size as the larger, and performs the bitwise AND operation, returning the resulting BigNumber
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: Bitwise AND of the two BigNumbers with a size of the larger BigNumber
    static func & <RHS>(lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.and(with: BigNumber(rhs))
    }
    
    /// Bitwise XOR operator
    ///
    /// Casts the smaller BigNumber to a BigNumber of the same size as the larger, and performs the bitwise XOR operation, returning the resulting BigNumber
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: Bitwise XOR of the two BigNumbers with a size of the larger BigNumber
    static func ^ <RHS>(lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.xor(with: BigNumber(rhs))
    }
    
    /// Left bitshifts the given BigNumber by a given integer amount with overflow handling. When the result would be of a bigger size than the
    /// given ```BN```, a new ```UInt64``` is appended to the array
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to bitshift
    ///     - rhs: Amount to bit shift
    ///
    /// - Returns: Exactly what you would expect
    static func << <RHS>(lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.leftShift(by: BigNumber(rhs))
    }
    
    /// Right bitshifts the given BigNumber by a given integer amount
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to bitshift
    ///     - rhs: Amount to bit shift
    ///
    /// - Returns: Exactly what you would expect
    static func >> <RHS>(lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.rightShift(by: BigNumber(rhs))
    }
    
    // MARK: Arithmetic Operators
    
    /// Adds two BigNumbers and assigns the sum to the left operand
    ///
    /// This will add elements to the array if needed
    ///
    /// - Parameters:
    ///     - a: BigNumber to add and also the variable to store the result
    ///     - rhs: BigNumber to add to ```a```
    ///
    /// - Returns: Sum of ```a``` and ```rhs```
    static func += (lhs: inout BigNumber, rhs: BigNumber) {
        lhs.add(rhs)
    }
    
    static func -= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs.subtract(rhs)
    }
    
    /**
     *
     * Multiplication assignment operator
     *
     * - Parameters:
     *      - lhs: multiplicand
     *      - rhs: multiplier
     */
    static func *= (lhs: inout BigNumber, rhs: BigNumber) {
        multiply(x: lhs, y: rhs, result: &lhs)
    }
    
    /**
     * Division assignment operator
     *
     * - Parameters:
     *      - lhs: dividend, as well as the `UBN` to store the output of the division
     *      - rhs: divisor
     */
    static func /= <RHS> (lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        var r = BN()
        divide(dividend: lhs, divisor: BigNumber(rhs), quotient: &lhs, remainder: &r)
    }
    
    static func %= (lhs: inout BigNumber, rhs: BigNumber) {
        var q = BN()
        divide(dividend: lhs, divisor: rhs, quotient: &q, remainder: &lhs)
        while lhs < 0 {
            lhs.add(rhs)
        }
    }
    
    // MARK: Non-Assignment Arithmetic Operators
    
    
    /// Adds two BigNumbers
    ///
    /// This will add elements to the array if needed
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to add
    ///     - rhs: BigNumber to add
    ///
    /// - Returns: Sum of ```lhs``` and ```rhs```
    static func + (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var a = lhs
        return a.add(rhs)
    }
    
    /// Subtraction
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber to subtract from ```lhs```
    ///
    /// - Returns: Difference of ```lhs``` and ```rhs```
    static func - (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var a = lhs
        return a.subtract(rhs)
    }
    
    /// Multiplies two BigNumbers
    ///
    /// - Parameters:
    ///     - lhs: A BigNumber to multiply
    ///     - rhs: A BigNumber to multiply
    ///
    /// - Returns: Product of ```lhs``` and ```rhs```
    static func * (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var p = BN()
        BigNumber.multiply(x: lhs, y: rhs, result: &p)
        return p
    }
    
    /// Divides two BigNumbers
    ///
    /// - Parameters:
    ///     - lhs: A BigNumber to divide
    ///     - rhs: BigNumber to divide ```rhs``` by
    ///
    /// - Returns: Product of ```lhs``` and ```rhs```
    static func / (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var a = lhs
        a /= rhs
        return a
    }
    
    /// Modulo operation for two ```BigNumber```'s
    ///
    /// - Parameters:
    ///     - lhs: ```BigNumber``` to modulo by another ```BigNumber```
    ///     - rhs: ```BigNumber``` by which to modulo
    ///
    /// - Returns: ```lhs``` modulo ```rhs```
    static func % (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var a = lhs
        a %= rhs
        return a
    }
    
    static prefix func - (x: BigNumber) -> BigNumber {
        x.negative
    }
    
    // MARK: Private functions
    
    /// Returns the maximum of two comparables
    ///
    /// This function is being added to avoid ambiguity with the static property ```max``` which was giving me errors because
    /// a ```UBigNumber``` does not conform to ```FixedWidthInteger```
    ///
    /// The reason this is being redeclafred is because of ambiguity errors
    ///
    /// - Parameters:
    ///     - a: Value to compare
    ///     - b: Another value to compate
    ///
    /// - Returns: The maximum of ```a``` and ```b```. If equal, it returns ```b```.
    private static func maxOf<T: Comparable>(_ a: T, _ b: T) -> T {
        return a > b ? a : b
    }
    
}
