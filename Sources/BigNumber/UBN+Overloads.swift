//
//  File.swift
//  
//
//  Created by Sylvan Martin on 10/25/19.
//

import Foundation
import CryptoKit

precedencegroup ExponentiationPrecedence {
    higherThan: MultiplicationPrecedence
    lowerThan: BitwiseShiftPrecedence
    associativity: none
    assignment: false
}

/// Exponentiation operator to be used with modular exponentiation modifier
infix operator **: ExponentiationPrecedence

extension UBigNumber: Comparable, Equatable {
    
    // MARK: - Comparative Operators
    
    /// Compares two BigNumbers, returns true if they are equal
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to compare
    ///     - rhs: Another BigNumber to compare
    ///
    /// - Returns: True if they are equal, false if not
    public static func == (lhs: UBigNumber, rhs: UBigNumber) -> Bool {
        lhs.equals(rhs)
    }
    
    /// Compares two BigNumbers and retuns true if they are not equal
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to compare
    ///     - rhs: Another BigNumber to compare
    ///
    /// - Returns: True if they are equal, false if not
    public static func != (lhs: UBigNumber, rhs: UBigNumber) -> Bool {
        !lhs.equals(rhs)
    }
    
    /// Greater than operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if lhs > rpublic hs
    public static func > (lhs: UBigNumber, rhs: UBigNumber) -> Bool {
        lhs.compare(to: rhs) > 0
    }
    
    /// Less than operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if lhs is less than rhs
    public static func < (lhs: UBigNumber, rhs: UBigNumber) -> Bool {
        lhs.compare(to: rhs) < 0
    }
    
    /// Greater than or Equal to Operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: Trpublic ue if lhs >= rhs
    public static func >= (lhs: UBigNumber, rhs: UBigNumber) -> Bool {
        return lhs > rhs || lhs == rhs
    }
    
    /// Less than or Equal to Operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if `lhs` is less than or equal to
    public static func <= (lhs: UBigNumber, rhs: UBigNumber) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    
    // MARK: - Range Operators
    
    /// Returns a range of all values between two values, inclusive
    ///
    /// - Parameters:
    ///     - a: Lower bound
    ///     - b: Upper bound
    ///
    /// - Returns: An range of all values between ```a``` and ```b```, inclusive
    public static func ... <RHS: BinaryInteger>(lhs: UBigNumber, rhs: RHS) -> ClosedRange<UBigNumber> {
        ClosedRange<UBigNumber>(uncheckedBounds: (lower: lhs, upper: UBN(rhs)))
    }
    
    /// Returns all values between two values, excluding the upper bound
    ///
    /// - Parameters:
    ///     - a: Lower bound
    ///     - b: Upper bound
    ///
    /// - Returns: An array of all values between ```a``` and ```b```, excluding ```b```
    public static func ..< <RHS: BinaryInteger>(lhs: UBigNumber, rhs: RHS) -> Range<UBigNumber> {
        Range<UBigNumber>(uncheckedBounds: (lower: lhs, upper: UBN(rhs)))
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
    public static func |= <RHS>(lhs: inout UBigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.or(with: rhs)
    }
    
    /// Stores the result of performing a bitwise AND operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
    public static func &= <RHS>(lhs: inout UBigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.and(with: rhs)
    }
    
    /// Stores the result of performing a bitwise XOR operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
    public static func ^= <RHS>(lhs: inout UBigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.xor(with: rhs)
    }
    
    /// Left bitshifts a value by another, and stores the result in the left hand side variable, with no overflow handling
    ///
    /// - Parameters:
    ///     - a: value to left bitshift
    ///     - b: amoutnt by which to left bitshift
    public static func &<<= <RHS>(lhs: inout UBigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.leftShift(by: rhs, withOverflowHandling: false)
    }
    
    /// Left bitshifts a value by another, and stores the result in the left hand side variable
    ///
    /// - Parameters:
    ///     - a: value to left bitshift
    ///     - b: amoutnt by which to left bitshift
    public static func <<= <RHS>(lhs: inout UBigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.leftShift(by: rhs)
    }
    
    /// Right bitshifts a value by another, and stores the result in the left hand side variable
    /// Currently, this only actually works when bitshifting by a number smaller than 64. :(
    ///
    /// - Parameters:
    ///     - a: value to right bitshift
    ///     - b: amoutnt by which to right bitshift
    public static func >>= <RHS>(lhs: inout UBigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.rightShift(by: rhs)
    }
    
    /// One's compliment
    ///
    /// - Parameters:
    ///     - rhs: The BigNumber to get the compliment of
    ///
    /// - Returns: The binary compliment of the BigNumber
    public static prefix func ~ (rhs: UBigNumber) -> UBigNumber {
        UBigNumber( rhs.words.map { ~($0) } )
    }
    
    /// Bitwise OR operator
    ///
    /// Casts the smaller BigNumber to a BigNumber of the same size as the larger, and performs the bitwise OR operation, returning the resulting BigNumber
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: Bitwise OR of the two BigNumbers
    public static func | <RHS>(lhs: UBigNumber, rhs: RHS) -> UBigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.or(with: rhs)
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
    public static func & <RHS>(lhs: UBigNumber, rhs: RHS) -> UBigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.and(with: rhs)
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
    public static func ^ <RHS>(lhs: UBigNumber, rhs: RHS) -> UBigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.xor(with: rhs)
    }
    
    /// Left bitshifts the given BigNumber by a given integer amount, with no overflow handling
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to bitshift
    ///     - rhs: Amount to bit shift
    ///
    /// - Returns: Exactly what you would expect
    static func &<< <RHS>(lhs: UBigNumber, rhs: RHS) -> UBigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.leftShift(by: rhs, withOverflowHandling: false)
    }
    
    /// Left bitshifts the given BigNumber by a given integer amount with overflow handling. When the result would be of a bigger size than the
    /// given ```BN```, a new ```UInt64``` is appended to the array
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to bitshift
    ///     - rhs: Amount to bit shift
    ///
    /// - Returns: Exactly what you would expect
    public static func << <RHS>(lhs: UBigNumber, rhs: RHS) -> UBigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.leftShift(by: rhs)
    }
    
    /// Right bitshifts the given BigNumber by a given integer amount
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to bitshift
    ///     - rhs: Amount to bit shift
    ///
    /// - Returns: Exactly what you would expect
    public static func >> <RHS>(lhs: UBigNumber, rhs: RHS) -> UBigNumber where RHS : BinaryInteger {
        var a = lhs
        return a.rightShift(by: rhs)
    }
    
    // MARK: Arithmetic Operators
    
    /// Adds two ```UBigNumber```s with no overflow handling. Any numbers that would usually be carried instead
    /// result in an overflow
    ///
    /// - Parameters:
    ///   - lhs: ```UBigNumber``` to increment
    ///   - rhs: ```UBigNumber``` to add to ```lhs```
    public static func &+= (lhs: inout UBigNumber, rhs: UBigNumber) {
        lhs.add(rhs, withOverflowHandling: false)
    }
    
    /// Adds two BigNumbers and assigns the sum to the left operand
    ///
    /// This will add elements to the array if needed
    ///
    /// - Parameters:
    ///     - a: BigNumber to add and also the variable to store the result
    ///     - rhs: BigNumber to add to ```a```
    ///
    /// - Returns: Sum of ```a``` and ```rhs```
    public static func += (lhs: inout UBigNumber, rhs: UBigNumber) {
        lhs.add(rhs)
    }
    
    public static func -= (lhs: inout UBigNumber, rhs: UBigNumber) {
        lhs.subtract(rhs)
    }
    
    /**
     * Multiplication Assignment operator with no overflow handling
     *
     * - Parameters:
     *      - lhs: multiplicand
     *      - rhs: multiplier
     */
    public static func &*= (lhs: inout UBigNumber, rhs: UBigNumber) {
        UBigNumber.multiply(x: lhs, by: rhs, result: &lhs, withOverflowHandling: false)
    }
    
    /**
     *
     * Multiplication assignment operator
     *
     * - Parameters:
     *      - lhs: multiplicand
     *      - rhs: multiplier
     */
    public static func *= (lhs: inout UBigNumber, rhs: UBigNumber) {
        UBigNumber.multiply(x: lhs, by: rhs, result: &lhs)
    }
    
    /**
     * Division assignment operator
     *
     * - Parameters:
     *      - lhs: dividend, as well as the `UBN` to store the output of the division
     *      - rhs: divisor
     */
    public static func /= <RHS> (lhs: inout UBigNumber, rhs: RHS) where RHS : BinaryInteger {
        var r = UBN()
        divide(dividend: lhs, divisor: UBigNumber(rhs), quotient: &lhs, remainder: &r)
    }
    
    public static func %= (lhs: inout UBigNumber, rhs: UBigNumber) {
        assert(rhs != 0, "Cannot divide by 0")
        let divisor = rhs.normalized
        
        if lhs == 0 {
            return
        }
        
        
        let dividendBitWidth = lhs.size * 64
        let divisorBitWidth  = divisor.mostSignificantBitIndex
        let shiftedDivisor   = divisor << (dividendBitWidth - divisorBitWidth)
        
        while lhs >= divisor {
            var i = 0
            while i <= (dividendBitWidth - divisorBitWidth) {
                let positionedDivisor = shiftedDivisor >> i
                let portionOfDividend = (lhs << i) >> (dividendBitWidth - divisorBitWidth)
                
                if portionOfDividend >= divisor {
                    lhs -= positionedDivisor
                }
                
                i += 1
            }
        }
    }
    
    // MARK: Non-Assignment Arithmetic Operators
    
    /// Adds two BigNumbers, with no overflow handling
    ///
    /// This won't add any elements to the BigNumber array
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: Sum of lhs and rhs without overflow prevention
    public static func &+ (lhs: UBigNumber, rhs: UBigNumber) -> UBigNumber {
        var a = lhs
        return a.add(rhs, withOverflowHandling: false)
    }
    
    /// Adds two BigNumbers
    ///
    /// This will add elements to the array if needed
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to add
    ///     - rhs: BigNumber to add
    ///
    /// - Returns: Sum of ```lhs``` and ```rhs```
    public static func + (lhs: UBigNumber, rhs: UBigNumber) -> UBigNumber {
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
    public static func - (lhs: UBigNumber, rhs: UBigNumber) -> UBigNumber {
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
    public static func * (lhs: UBigNumber, rhs: UBigNumber) -> UBigNumber {
        var p = UBN()
        UBigNumber.multiply(x: lhs, by: rhs, result: &p)
        return p
    }
    
    /// Multiplies two BigNumbers with no overflow handling
    ///
    /// - Parameters:
    ///     - lhs: A BigNumber to multiply
    ///     - rhs: A BigNumber to multiply
    ///
    /// - Returns: Product of ```lhs``` and ```rhs```
    public static func &* (lhs: UBigNumber, rhs: UBigNumber) -> UBigNumber {
        var p = UBN()
        UBigNumber.multiply(x: lhs, by: rhs, result: &p, withOverflowHandling: false)
        return p
    }
    
    /// Divides two BigNumbers
    ///
    /// - Parameters:
    ///     - lhs: A BigNumber to divide
    ///     - rhs: BigNumber to divide ```rhs``` by
    ///
    /// - Returns: Product of ```lhs``` and ```rhs```
    public static func / (lhs: UBigNumber, rhs: UBigNumber) -> UBigNumber {
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
    public static func % (lhs: UBigNumber, rhs: UBigNumber) -> UBigNumber {
        var a = lhs
        a %= rhs
        return a
    }
    
    // MARK: Modular Exponentiation (Non-operator definitions)
    
    /**
     * Quickly computes A^B mod C
     *
     * - Parameters:
     *      - a: Base
     *      - b: Exponent
     *      - c: Modulo
     *
     * - Returns: ```a ^ b mod c```
     */
    public static func modExp(a: UBigNumber, b: UBigNumber, c: UBigNumber) -> UBigNumber {
        
        if b.isPowerOfTwo {
            return modExpPowerOfTwo(a: a, b: b, c: c)
        }
        
        var i = 0
        
        while (b >> i) % 2 == 0 {
            i += 1
        }
        
        var p = modExpPowerOfTwo(a: a, b: 1 << i, c: c)
        
        i += 1
        
        while b >> i > 0 {
            
            if (b >> i) % 2 == 1 {
                p *= modExpPowerOfTwo(a: a, b: 1 << i, c: c)
            }
            
            i += 1
        }
        
        return p % c
    }
    
    /**
     * Fast modular exponentiation for powers of two
     *
     * - Parameters:
     *      - a: Base
     *      - b: Exponent (Must be power of two)
     *      - c: Modulo
     *
     * - Returns ```a^b mod c``` where ```b``` is a power of two
     */
    public static func modExpPowerOfTwo(a: UBigNumber, b: UBigNumber, c: UBigNumber) -> UBigNumber {
        if b == 1 {
            return a % c
        }
        
//        let d = modExpPowerOfTwo(a: a, b: b >> 1, c: c) // for some reason, trying to only perform the computation once actually makes this function slower. No idea why.
        return (modExpPowerOfTwo(a: a, b: b >> 1, c: c) * modExpPowerOfTwo(a: a, b: b >> 1, c: c)) % c
    }
    
    // MARK: Modular Exponentiation (Operator Definitions)
    
    public static func **(base: UBigNumber, power: UBigNumber) -> (base: UBigNumber, power: UBigNumber) {
        (base: base, power: power)
    }
    
    public static func %(lhs: (base: UBigNumber, power: UBigNumber), rhs: UBigNumber) -> UBigNumber {
        return modExp(a: lhs.base, b: lhs.power, c: rhs)
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
