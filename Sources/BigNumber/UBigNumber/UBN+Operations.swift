//
//  File.swift
//  
//
//  Created by Sylvan Martin on 10/25/19.
//

import Foundation
import CryptoKit

fileprivate extension UBigNumber {
    
    // MARK: - Comparison
    
    /**
     * Checks if another `UBN` equals this one
     *
     * - Parameters:
     *      - other: `UBN` to compare
     *
     * - Returns: `true` if the numbers are numerically equivalent
     */
    func equals(_ other: UBigNumber) -> Bool {
        
        if other.size != self.size {
            return false
        }
        
        for i in 0..<self.size {
            if self[i] != other[i] {
                return false
            }
        }
        
        return true
        
    }
    
    /**
     * Compares this `UBN` to a `BinaryInteger, returning an `Int` representing their relation
     *
     * - Parameters:
     *      - other: `UBN` to compare
     *
     * - Returns: a positive integer if `self` is greater than `other`, a negative integer if `self` is less than `other`, and `0` if `self` is equal to `other`
     */
    func compare(to other: UBigNumber) -> Int {
        
        if self.size > other.size {
            return 1
        } else if self.size < other.size {
            return -1
        }

        // Compare most significant words
        for i in (0..<size).reversed() {
            if self[i] > other[i] {
                return 1
            }
            if self[i] < other[i] {
                return -1
            }
        }

        return 0

    }
    
    // MARK: - Bitwise Operations
    
    @discardableResult
    private mutating func applyWordwiseOp <T: BinaryInteger> (with other: T, operation: (WordType, WordType) -> WordType) -> UBigNumber {
        
        var otherWords = Words(other.words)
        otherWords += [WordType](repeating: 0, count: size > otherWords.count ? size - otherWords.count : 0)
        
        for i in 0..<otherWords.count {
            self[safe: i] = operation(self[safe: i], otherWords[i])
        }
        
        return normalize()
    }
    
    /**
     * OR's every word of this `UBigNumber` with the respective word of another `UBigNumber`
     *
     * - Parameters:
     *      - other: another `BinaryInteger` to OR with this one
     */
    @discardableResult mutating func or <T: BinaryInteger> (with other: T) -> UBigNumber {
        applyWordwiseOp(with: other, operation: |)
    }
    
    /**
     * AND's every word of this `UBigNumber` with the corresponding word of another `UBigNumber`
     *
     * - Parameters:
     *      - other: another `UBigNumber` to AND with this one
     */
    @discardableResult mutating func and <T: BinaryInteger> (with other: T) -> UBigNumber {
        applyWordwiseOp(with: other, operation: &)
    }
    
    /**
     * XOR's every word of this `UBigNumber` with the corresponding word of another `UBigNumber`
     *
     * - Parameters:
     *      - other: another `UBigNumber` to XOR with this one
     */
    @discardableResult mutating func xor <T: BinaryInteger> (with other: T) -> UBigNumber {
        applyWordwiseOp(with: other, operation: ^)
    }
    
    /**
     * Left shifts this `UBigNumber` by some integeral amount
     *
     * - Parameters:
     *      - shift: Amount by which to left shift this `UBigNumber`
     *      - handleOverflow: if `true`, this operation will append any necessary words to the `UInt` words of this `UBigNumber`
     */
    @discardableResult mutating func leftShift <T: BinaryInteger> (by shift: T) -> UBigNumber {
        
        if shift.signum() == -1 {
            rightShift(by: shift.magnitude)
        }
        
        if self.isZero || shift == 0 {
            return self
        }
        
        let wordShift = Int(shift) / WordType.bitWidth
        let bitShift  = Int(shift) % WordType.bitWidth
        
        // This is my implementation
        words += Words(repeating: 0, count: wordShift + (bitShift > mostSignificantWord.leadingZeroBitCount ? 1 : 0))

        for i in (wordShift..<size).reversed() {
            words[i] = words[i - wordShift]
        }

        for i in 0..<wordShift {
            words[i] = 0
        }

        for i in (1..<size).reversed() {
            words[i] <<= bitShift
            words[i] += words[i - 1] >> (WordType.bitWidth - bitShift)
        }

        words[0] <<= bitShift
        
        return self.normalize()
        
    }
    
    /**
     * Right shifts this `UBigNumber` by some integeral amount
     *
     * - Parameters:
     *   - shift: Amount by which to left shift this `BigNumber`
     */
    @discardableResult mutating func rightShift <T: BinaryInteger> (by shift: T) -> UBigNumber {
        
        if shift.signum() == -1 {
            leftShift(by: shift.magnitude)
        }
        
        let wordShift = Int(shift) / WordType.bitWidth
        let bitShift  = Int(shift) % WordType.bitWidth
        
        if wordShift >= size {
            self = 0
            return self
        }
        
        for i in 0..<(size - wordShift) {
            words[i] = words[i + wordShift]
        }
        
        for i in (size - wordShift)..<size {
            words[i] = 0
        }
        
        for i in 0..<(size - 1) {
            words[i] >>= bitShift
            words[i] += words[i + 1] << (WordType.bitWidth - bitShift)
        }
        words[size - 1] >>= bitShift
        
        return self.normalize()
        
    }
    
    // MARK: - Arithmetic Operations
    
    /**
     * Adds another `BinaryInteger` to this `UBigNumber`
     *
     * - Parameters:
     *   - other: A `BinaryInteger` to add to this `UBigNumber`
     *   - handleOverflow: if `true`, this operation will append any necessary words to this `UBigNumber`
     *
     * - Returns: Sum of `self` and `other`
     */
    @discardableResult mutating func add <T: BinaryInteger> (_ other: T, withOverflowHandling handleOverflow: Bool = true) -> UBigNumber {
        
        let b = UBN(other)
        
        var carry: UInt
        
        let size = handleOverflow ? Swift.max(self.size, b.size) + 1 : size
        
        if size > self.size {
            self.words += Words(repeating: 0, count: size - self.size)
        }
        
        carry = 0
        
        for i in 0..<size {
            self[i] &+= carry
            carry = self[i] < carry ? 1 : 0
            self[i] &+= b[safe: i]
            carry = self[i] < b[safe: i] ? 1 : carry
        }
        
        return self.normalize()
        
    }
    
    /// Subtracts a numerical value from this `UBN`
    /// - Parameter other: `BinaryInteger` to subtract
    /// - Returns: difference of `self` and `other`
    @discardableResult mutating func subtract(_ other: UBigNumber) -> UBigNumber {
        var b = other
        
        if b.size < self.size {
            b.words += Words(repeating: 0, count: self.size - b.size)
        }
        
        var twosCompliment = ~b
        twosCompliment.add(1, withOverflowHandling: false)
        self.add(twosCompliment, withOverflowHandling: false)
        
        return self.normalize()
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
    func multiply(_ other: UBigNumber) -> UBigNumber {
        
        var result: UBN = 0
        
        var carry: UInt = 0
        var i = 0
        
        if result.size < self.size + other.size {
            result.words = Words(repeating: 0, count: self.size + other.size)
        }
        
        if self == 0 || other == 0 {
            return 0
        }
        
        if self == 1 {
            return other
        }
        
        if other == 1 {
            return self
        }
        
        for j in 0..<other.size {
            carry = 0
            
            i = 0
            while i < self.size {
                UInt.addmul(lo: &result[i+j], hi: &carry, a: self[i], b: other[j], c: carry, d: result[i+j])
                i += 1 // Swift doesn't have C-style for loops :(
            }
            
            result[i+j] = carry
            
        }
        
        result.normalize()
        
        return result
        
    }
    
}

extension UBigNumber: Comparable, Equatable {
    
    /**
     * Divides `self` by `divisor`, and stores the quotient and remainder in given objects
     *
     * - Parameters:
     *      - divisor: `BinaryInteger`
     *      - quotient: `UBigNumber` object that stores the quotient
     *      - remainder: `UBigNumber` object that stores the remainder
     */
    public func quotientAndRemainder(dividingBy divisor: UBigNumber) -> (quotient: UBigNumber, remainder: UBigNumber) {
        
        var quotient: UBigNumber = 0
        var remainder = self
        
        let cmp = self.compare(to: divisor)
        
        if divisor == 0 {
            fatalError("Cannot divide by 0")
        }
        
        if cmp == -1 {
            return (quotient, remainder)
        }
            
        else if cmp == 0 {
            return (1, 0)
        }
        
        if quotient.size < self.size - divisor.size + 1 {
            quotient.words = Words(repeating: 0, count: self.size - divisor.size + 1)
        }
        
        var partialProduct: UBigNumber = 0
        
        while remainder >= divisor {
            
            var partialQuotient: UBigNumber = 1
            
            if remainder.mostSignificantWord >= divisor.mostSignificantWord {
                // these are checking different actual words. the MSW of remainder may be its 2nd word, MSB of divisor might be 1st word. is that okay?
                partialQuotient.leastSignificantWord = remainder.mostSignificantWord / divisor.mostSignificantWord
                
                partialQuotient.leftShift(by: (remainder.size - divisor.size) * WordType.bitWidth)
            }
            else {
                partialQuotient.leftShift(by: (remainder.size - divisor.size) * WordType.bitWidth
                                          + divisor.mostSignificantWord.leadingZeroBitCount
                                          - remainder.mostSignificantWord.leadingZeroBitCount)
            }
            
            
            partialProduct = divisor * partialQuotient
            
            while partialProduct > remainder {
                
                if partialQuotient.leastSignificantWord & 1 == 0 {
                    partialProduct.rightShift(by: 1)
                    partialQuotient.rightShift(by: 1)
                }
                else {
                    partialQuotient.leastSignificantWord -= 1
                    partialProduct.subtract(divisor)
                }
                
            }
            
            remainder -= partialProduct
            quotient += partialQuotient
            
        }
        
        return (quotient, remainder)
        
    }
    
    // MARK: - Comparative Operators
    
    /// Compares two `UBigNumbers`, returns true if they are equal
    ///
    /// - Parameters:
    ///     - lhs: `UBigNumber` to compare
    ///     - rhs: Another `UBigNumber` to compare
    ///
    /// - Returns: `true` if `lhs` and `rhs` are numerically equivalent, `false` if not.
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
    /// - Returns: True if lhs > rhs
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
    /// - Returns: True if lhs >= rhs
    public static func >= (lhs: UBigNumber, rhs: UBigNumber) -> Bool {
        lhs.compare(to: rhs) >= 0
    }
    
    /// Less than or Equal to Operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if `lhs` is less than or equal to
    public static func <= (lhs: UBigNumber, rhs: UBigNumber) -> Bool {
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
    ///     - ubn: The `UBigNumber` to get the compliment of
    ///
    /// - Returns: The binary compliment of `ubn`
    public static prefix func ~ (ubn: UBigNumber) -> UBigNumber {
        UBN(array: ubn.words.map{ ~$0 })
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
     *
     * Multiplication assignment operator
     *
     * - Parameters:
     *      - lhs: multiplicand
     *      - rhs: multiplier
     */
    public static func *= (lhs: inout UBigNumber, rhs: UBigNumber) {
        lhs = rhs
    }
    
    /**
     * Division assignment operator
     *
     * - Parameters:
     *      - lhs: dividend, as well as the `UBN` to store the output of the division
     *      - rhs: divisor
     */
    public static func /= (lhs: inout UBigNumber, rhs: UBigNumber) {
        lhs = lhs.quotientAndRemainder(dividingBy: rhs).quotient
    }
    
    public static func %= (lhs: inout UBigNumber, rhs: UBigNumber) {
        lhs = lhs.quotientAndRemainder(dividingBy: rhs).remainder
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
        lhs.multiply(rhs)
    }
    
    /// Divides two BigNumbers
    ///
    /// - Parameters:
    ///     - lhs: A BigNumber to divide
    ///     - rhs: BigNumber to divide ```rhs``` by
    ///
    /// - Returns: Product of ```lhs``` and ```rhs```
    public static func / (lhs: UBigNumber, rhs: UBigNumber) -> UBigNumber {
        lhs.quotientAndRemainder(dividingBy: rhs).quotient
    }
    
    /// Modulo operation for two ```BigNumber```'s
    ///
    /// - Parameters:
    ///     - lhs: ```BigNumber``` to modulo by another ```BigNumber```
    ///     - rhs: ```BigNumber``` by which to modulo
    ///
    /// - Returns: ```lhs``` modulo ```rhs```
    public static func % (lhs: UBigNumber, rhs: UBigNumber) -> UBigNumber {
        lhs.quotientAndRemainder(dividingBy: rhs).remainder
    }
    
    /**
     * Raises `self` to the power of `power`
     */
    func pow(_ power: UBigNumber) -> UBigNumber {
        // TODO: Make this not super slow!
        
        var countdown = power
        var product = UBN(1)
        
        while countdown != 0 {
            product *= self
            countdown -= 1
        }
        
        return product
        
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
