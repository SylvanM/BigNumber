//
//  File.swift
//  
//
//  Created by Sylvan Martin on 5/31/22.
//

import Foundation

fileprivate extension BigNumber {
    
    // MARK: Comparisons
    
    func equals(_ other: BigNumber) -> Bool {
        
        if self.sign != other.sign {
            return false
        }
        
        return self.magnitude == other.magnitude
        
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
            self.magnitude += other.magnitude
            return self
        }
        
        if self.sign == 0 {
            self = other
            return self
        }
        
        if self.sign == 1 { // at this point, the other number must be negative
            self -= other.negative
            return self
        }
        
        // if this number is negative and the other is positive...
        
        let negSelf = self.negative
        
        self.magnitude = other.magnitude
        self.sign = other.sign
        
        self -= negSelf
        
        return self
        
    }
    
    /// Subtracts a numerical value from this `UBN`
    /// - Parameter other: `BinaryInteger` to subtract
    /// - Returns: difference of `self` and `other`
    @discardableResult mutating func subtract (_ other: BigNumber) -> BigNumber {
        
        if other.sign == -1 {
            self += other.negative
            return self
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
                self.magnitude -= other.magnitude
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
        self.magnitude += other.magnitude
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
    func multiply (_ other: BigNumber) -> BigNumber {
        
        var result: BN = 0
        
        if self.sign == other.sign {
            result.sign = 1
        } else {
            result.sign = -1
        }
        
        result.magnitude = self.magnitude * other.magnitude
        
        result.normalize()
        
        return result
        
    }
    
}

public extension BigNumber {
    
    /**
     * Divides `self` by `divisor`, and stores the quotient and remainder in given objects
     *
     * - Parameters:
     *      - divisor: `BinaryInteger`
     */
    func quotientAndRemainder(dividingBy divisor: BigNumber) -> (quotient: BigNumber, remainder: BigNumber) {
        
        var quotient: BN = 0
        var remainder: BN = 0
        
        if self.signum() == divisor.signum() {
            quotient.sign = 1
        } else {
            quotient.sign = -1
        }
        
        remainder.sign = self.sign
        
        (quotient.magnitude, remainder.magnitude) = self.magnitude.quotientAndRemainder(dividingBy: divisor.magnitude)
        
        quotient.normalize()
        remainder.normalize()
        
        return (quotient, remainder)
        
    }
    
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
        if lhs.sign > rhs.sign {
            return true
        } else if lhs.sign == rhs.sign {
            if lhs.sign == -1 {
                return lhs.magnitude < rhs.magnitude
            } else {
                return lhs.magnitude > rhs.magnitude
            }
        } else {
            return false
        }
    }
    
    /// Less than operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if lhs is less than rhs
    static func < (lhs: BigNumber, rhs: BigNumber) -> Bool {
        if lhs.sign < rhs.sign {
            return true
        } else if lhs.sign == rhs.sign {
            if lhs.sign == -1 {
                return lhs.magnitude > rhs.magnitude
            } else {
                return lhs.magnitude < rhs.magnitude
            }
        } else {
            return false
        }
    }
    
    /// Greater than or Equal to Operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if lhs >= rhs
    static func >= (lhs: BigNumber, rhs: BigNumber) -> Bool {
        lhs > rhs || lhs == rhs
    }
    
    /// Less than or Equal to Operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if `lhs` is less than or equal to
    static func <= (lhs: BigNumber, rhs: BigNumber) -> Bool {
        lhs < rhs || lhs == rhs
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
        lhs.magnitude |= rhs.magnitude
    }
    
    /// Stores the result of performing a bitwise AND operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
    static func &= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.magnitude &= rhs.magnitude
    }
    
    /// Stores the result of performing a bitwise XOR operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
    static func ^= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.magnitude ^= rhs.magnitude
    }
    
    /// Left bitshifts a value by another, and stores the result in the left hand side variable
    ///
    /// - Parameters:
    ///     - a: value to left bitshift
    ///     - b: amoutnt by which to left bitshift
    static func <<= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        if rhs.signum() == -1 {
            lhs >>= rhs * -1
        } else {
            lhs.magnitude <<= rhs.magnitude
        }
    }
    
    /// Right bitshifts a value by another, and stores the result in the left hand side variable
    /// Currently, this only actually works when bitshifting by a number smaller than 64. :(
    ///
    /// - Parameters:
    ///     - a: value to right bitshift
    ///     - b: amoutnt by which to right bitshift
    static func >>= <RHS>(lhs: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        if rhs.signum() == -1 {
            lhs <<= rhs * -1
        } else {
            lhs.magnitude >>= rhs.magnitude
        }
    }
    
    /// One's compliment
    ///
    /// - Parameters:
    ///     - ubn: The `UBigNumber` to get the compliment of
    ///
    /// - Returns: The binary compliment of `ubn`
    static prefix func ~ (bn: BigNumber) -> BigNumber {
        BN(sign: bn.sign, magnitude: ~(bn.magnitude))
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
        a |= rhs
        return a
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
        a &= rhs
        return a
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
        a ^= rhs
        return a
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
        a <<= rhs
        return a
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
        a >>= rhs
        return a
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
        lhs = lhs.multiply(rhs)
    }
    
    /**
     * Division assignment operator
     *
     * - Parameters:
     *      - lhs: dividend, as well as the `UBN` to store the output of the division
     *      - rhs: divisor
     */
    static func /= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs = lhs.quotientAndRemainder(dividingBy: rhs).quotient
    }
    
    static func %= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs = lhs.quotientAndRemainder(dividingBy: rhs).remainder
        while lhs < 0 { lhs.add(rhs) }
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
        lhs.multiply(rhs)
    }
    
    /// Divides two BigNumbers
    ///
    /// - Parameters:
    ///     - lhs: A BigNumber to divide
    ///     - rhs: BigNumber to divide ```rhs``` by
    ///
    /// - Returns: Product of ```lhs``` and ```rhs```
    static func / (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        lhs.quotientAndRemainder(dividingBy: rhs).quotient
    }
    
    /// Modulo operation for two ```BigNumber```'s
    ///
    /// - Parameters:
    ///     - lhs: ```BigNumber``` to modulo by another ```BigNumber```
    ///     - rhs: ```BigNumber``` by which to modulo
    ///
    /// - Returns: ```lhs``` modulo ```rhs```
    static func % (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        lhs.quotientAndRemainder(dividingBy: rhs).remainder
    }
    
    static prefix func - (x: BigNumber) -> BigNumber {
        x.negative
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
