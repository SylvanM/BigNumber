//
//  File.swift
//  
//
//  Created by Sylvan Martin on 10/25/19.
//

import Foundation

precedencegroup ExponentiationPrecedence {
    higherThan: MultiplicationPrecedence
    lowerThan: BitwiseShiftPrecedence
    associativity: none
    assignment: false
}

/// Exponentiation operator to be used with modular exponentiation modifier
infix operator **: ExponentiationPrecedence

extension UBigNumber: BinaryInteger, Comparable, Equatable {
    
    // MARK: - Casting
    
    /// Matches the sizes of ```a``` and ```b``` with each other. This will change the array size
    /// of the smaller one to the larger
    ///
    /// 
    static func matchSizes(a: inout UBigNumber, b: inout UBigNumber) {
        let size = maxOf(a.array.count, b.array.count)
        
        while a.size < size {
            a.array.append(0)
        }
        
        while b.size < size {
            b.array.append(0)
        }
        
    }
    
    // MARK: - Comparative Operators
    
    /// Compares two BigNumbers, returns true if they are equal
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to compare
    ///     - rhs: Another BigNumber to compare
    ///
    /// - Returns: True if they are equal, false if not
    public static func == (lhs: UBigNumber, rhs: UBigNumber) -> Bool {
        let a = lhs.erasingLeadingZeros
        let b = rhs.erasingLeadingZeros
        
        return a.array == b.array
    }
    
    /// Compares two BigNumbers and retuns true if they are not equal
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to compare
    ///     - rhs: Another BigNumber to compare
    ///
    /// - Returns: True if they are equal, false if not
    public static func != (lhs: UBigNumber, rhs: UBigNumber) -> Bool {
        let a = lhs.erasingLeadingZeros
        let b = rhs.erasingLeadingZeros
        
        return a.array != b.array
    }
    
    /// Greater than operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if lhs > rpublic hs
    public static func > (lhs: UBigNumber, rhs: UBigNumber) -> Bool {
        let a = lhs.erasingLeadingZeros
        let b = rhs.erasingLeadingZeros
        
        if      a.size > b.size { return true  }
        else if a.size > b.size { return false }
        
        // the sizes are equal at this point
        for i in (0..<a.size).reversed() {
            if a[i] > b[i] {
                return true
            }
        }
        
        return false
    }
    
    /// Less than operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if lhs is less than rhs
    public static func < (lhs: UBigNumber, rhs: UBigNumber) -> Bool {
        let a = lhs.erasingLeadingZeros
        let b = rhs.erasingLeadingZeros
        if      a.size < b.size { return true  }
        else if b.size < a.size { return false }
        
        // the sizes are equal at this point
        for i in (0..<a.size).reversed() {
            if a[i] >= b[i] {
                return false
            }
        }
        
        return true
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
    
    /// Returns all values between two values, inclusive
    ///
    /// - Parameters:
    ///     - a: Lower bound
    ///     - b: Upper bound
    ///
    /// - Returns: An array of all values between ```a``` and ```b```
    public static func ... <RHS: BinaryInteger>(lhs: UBigNumber, rhs: RHS) -> ClosedRange<UBigNumber> {
        ClosedRange<UBigNumber>(uncheckedBounds: (lower: lhs, upper: UBigNumber(rhs)))
    }
    
    /// Returns all values between two values, excluding the upper bound
    ///
    /// - Parameters:
    ///     - a: Lower bound
    ///     - b: Upper bound
    ///
    /// - Returns: An array of all values between ```a``` and ```b```, excluding ```b```
    public static func ..< <RHS: BinaryInteger>(lhs: UBigNumber, rhs: RHS) -> Range<UBigNumber> {
        Range<UBigNumber>(uncheckedBounds: (lower: lhs, upper: UBigNumber(rhs)))
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
        let b = UBN(rhs)
        for i in 0..<maxOf(lhs.size, b.size) {
            lhs[i] |= b[i]
        }
    }
    
    /// Stores the result of performing a bitwise AND operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
    public static func &= <RHS>(lhs: inout UBigNumber, rhs: RHS) where RHS : BinaryInteger {
        let b = UBN(rhs)
        for i in 0..<maxOf(lhs.size, b.size) {
            lhs[i] &= b[i]
        }
    }
    
    /// Stores the result of performing a bitwise XOR operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
    public static func ^= <RHS>(lhs: inout UBigNumber, rhs: RHS) where RHS : BinaryInteger {
        let b = UBN(rhs)
        for i in 0..<maxOf(lhs.size, b.size) {
            lhs[i] ^= b[i]
        }
    }
    
    /// Left bitshifts a value by another, and stores the result in the left hand side variable, with no overflow handling
    ///
    /// - Parameters:
    ///     - a: value to left bitshift
    ///     - b: amoutnt by which to left bitshift
    public static func &<<= <RHS>(lhs: inout UBigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.setShouldEraseLeadingZeros(to: false)
        
        if lhs.size == 0 || rhs == 0 {
            lhs.setShouldEraseLeadingZeros(to: true)
            return
        }
        
        let wordShift: Int = Int(rhs / 64) // words to shift by
        let bitShift:  Int = Int(rhs % 64) // bits going to be shifted
        
        // shift by the words, then by the bits
        // aka shift the array, then shift the bits by bitShift
        for i in (0..<lhs.size).reversed() {
            if wordShift > i {
                lhs[i] = 0
                continue
            }
            lhs[i] = lhs[i - wordShift]
        }
        
        // now shift the bits
        for i in (1..<lhs.size).reversed() {
            lhs[i] &<<= bitShift
            lhs[i] += lhs[i-1] >> (64 - bitShift)
        }
        lhs[0] &<<= bitShift
        
        lhs.setShouldEraseLeadingZeros(to: true)
    }
    
    /// Left bitshifts a value by another, and stores the result in the left hand side variable
    ///
    /// - Parameters:
    ///     - a: value to left bitshift
    ///     - b: amoutnt by which to left bitshift
    public static func <<= <RHS>(lhs: inout UBigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.setShouldEraseLeadingZeros(to: false)
        
        if lhs.size == 0 || rhs == 0 {
            lhs.setShouldEraseLeadingZeros(to: true)
            return
        }
        
        let wordShift: Int = Int(rhs / 64) // words to shift by
        let bitShift:  Int = Int(rhs % 64) // bits going to be shifted
        
        // shift by the words, then by the bits
        // aka shift the array, then shift the bits by bitShift
        let newSize = wordShift + lhs.size
        while lhs.size < newSize {
            lhs.array.append(0)
        }
        
        for i in (0..<lhs.size).reversed() {
            if wordShift > i {
                lhs[i] = 0
                continue
            }
            lhs[i] = lhs[i - wordShift]
        }
        
        // now shift the bits
        
        // if the last bitShift bits of the last element of a are nonzero, then we have to allocate new memory
        // because they will be carried to a new array element
        
        if lhs[lhs.size - 1] >> (64 - UInt64(bitShift)) > 0 {
            lhs.array.append(0)
        }
        
        for i in (1..<lhs.size).reversed() {
            lhs[i] &<<= bitShift
            lhs[i] += lhs[i-1] >> (64 - bitShift)
        }
        lhs[0] &<<= bitShift
        
        lhs.setShouldEraseLeadingZeros(to: true)
    }
    
    /// Right bitshifts a value by another, and stores the result in the left hand side variable
    /// Currently, this only actually works when bitshifting by a number smaller than 64. :(
    ///
    /// - Parameters:
    ///     - a: value to right bitshift
    ///     - b: amoutnt by which to right bitshift
    public static func >>= <RHS>(lhs: inout UBigNumber, rhs: RHS) where RHS : BinaryInteger {
        lhs.setShouldEraseLeadingZeros(to: false)
        
        if lhs.size == 0 || rhs == 0 {
            lhs.setShouldEraseLeadingZeros(to: true)
            return
        }
        
        let wordShift: Int = Int(rhs / 64) // words to shift by
        let bitShift:  Int = Int(rhs % 64) // bits going to be shifted
        
        // shift by the words, then by the bits
        // aka shift the array, then shift the bits by bitShift
        for i in (0..<lhs.size) {
            if wordShift + i >= lhs.size {
                lhs[i] = 0
                continue
            }
            lhs[i] = lhs[i + wordShift]
        }
        
        // now shift the bits
        
        for i in 0..<(lhs.size - 1) {
            lhs[i] >>= bitShift
            lhs[i] += lhs[i+1] << (64 - bitShift)
        }
        lhs[lhs.size-1] >>= bitShift
        
        lhs.setShouldEraseLeadingZeros(to: true)
    }
    
    /// One's compliment
    ///
    /// - Parameters:
    ///     - rhs: The BigNumber to get the compliment of
    ///
    /// - Returns: The binary compliment of the BigNumber
    public static prefix func ~ (rhs: UBigNumber) -> UBigNumber {
        UBigNumber( rhs.array.map { ~($0) } )
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
    public static func & <RHS>(lhs: UBigNumber, rhs: RHS) -> UBigNumber where RHS : BinaryInteger {
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
    public static func ^ <RHS>(lhs: UBigNumber, rhs: RHS) -> UBigNumber where RHS : BinaryInteger {
        var a = lhs
        a ^= rhs
        return a
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
        a &<<= rhs
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
    public static func << <RHS>(lhs: UBigNumber, rhs: RHS) -> UBigNumber where RHS : BinaryInteger {
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
    public static func >> <RHS>(lhs: UBigNumber, rhs: RHS) -> UBigNumber where RHS : BinaryInteger {
        var a = lhs
        a >>= rhs
        return a
    }
    
    // MARK: Arithmetic Operators
    
    /// Adds two ```UBigNumber```s with no overflow handling. Any numbers that would usually be carried instead
    /// result in an overflow
    ///
    /// - Parameters:
    ///   - lhs: ```UBigNumber``` to increment
    ///   - rhs: ```UBigNumber``` to add to ```lhs```
    public static func &+= (lhs: inout UBigNumber, rhs: UBigNumber) {
        
        var carryOut: UInt64 = 0
        var carryIn:  UInt64 = 0
        
        let largerSize: Int = {
            let x = lhs.size
            let y = UBN(rhs).size
            return x >= y ? x : y
        }()
        
        for i in 0..<largerSize {
            let overflowStatus = lhs[i].addingReportingOverflow(UBN(rhs)[i])
            lhs[i] = overflowStatus.partialValue
            if overflowStatus.overflow {
                carryOut = 1
            }
            if carryIn != 0 {
                lhs[i] &+= 1
                if ( 0 == lhs[i] ) {
                    carryOut = 1
                }
            }
            carryIn = carryOut
            carryOut = 0
        }
        
        lhs.setShouldEraseLeadingZeros(to: true)
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
        var carryOut: UInt64 = 0
        var carryIn:  UInt64 = 0
        
        let b = UBN(rhs)
        
        let largerSize: Int = {
            let x = lhs.size
            let y = b.size
            return x >= y ? x : y
        }()
        
        for i in 0..<largerSize {
            let overflowStatus = lhs[i].addingReportingOverflow(b[i])
            lhs[i] = overflowStatus.partialValue
            
            if overflowStatus.overflow {
                carryOut = 1
            }
            
            if carryIn != 0 {
                lhs[i] &+= 1
                if ( 0 == lhs[i] ) {
                    carryOut = 1
                }
            }
            
            if carryOut == 1 && i == lhs.size - 1 {
                lhs.array.append(1)
            }
            
            carryIn = carryOut
            carryOut = 0
        }
        
        lhs.setShouldEraseLeadingZeros(to: true)
    }
    
    public static func -= (lhs: inout UBigNumber, rhs: UBigNumber) {
        lhs = ((UBN(~rhs) &+ 1) &+ lhs).erasingLeadingZeros
    }
    
    /**
     * Multiplication Assignment operator
     *
     * This works by computing the sum of all products of each factor of 2 of the rhs with lhs
     *
     * That is mathematically true because, for example, if the multiplier is 0b110010 and the multicand is n, then:
     * n • (0b110010) = n • (0b100000 + 0b10000 + 0b10) = n • 0b100000 + n • 0b10000 + n • 0b10
     *
     * - Parameters:
     *      - lhs: multiplicand
     *      - rhs: multiplier
     */
    public static func *= (lhs: inout UBigNumber, rhs: UBigNumber) {
        
        // I'm making these two different if statements so that it runs faster,
        // and in the event of the first one being true, it doesn't have to execute the second
        
        if lhs == 0 {
            return
        }
        
        if rhs == 0 {
            lhs = 0
            return
        }
        
        if rhs.isPowerOfTwo {
            lhs <<= rhs.mostSignificantBit
            return
        }
        
        var a = rhs
        var i = 0
        
        while (a[0] % 2) == 0 {
            a >>= 1
            i += 1
        }
        
        let originalLHS = lhs
        
        lhs <<= i
        
        while a != 0 {
            
            a >>= 1
            i += 1
            
            if (a[0] % 2) == 1 {
                lhs += originalLHS << i
            }
        }
    }
    
    /**
     * Multiplication Assignment operator with no overflow handling
     *
     * This works by computing the sum of all products of each factor of 2 of the rhs with lhs
     *
     * That is mathematically true because, for example, if the multiplier is 0b110010 and the multicand is n, then:
     * n • (0b110010) = n • (0b100000 + 0b10000 + 0b10) = n • 0b100000 + n • 0b10000 + n • 0b10
     *
     * - Parameters:
     *      - lhs: multiplicand
     *      - rhs: multiplier
     */
    public static func &*= (lhs: inout UBigNumber, rhs: UBigNumber) {
        
        // I'm making these two different if statements so that it runs faster,
        // and in the event of the first one being true, it doesn't have to execute the second
        
        if lhs == 0 {
            return
        }
        
        if rhs == 0 {
            lhs = 0
            return
        }
        
        // if rhs is a power of two, this process is a whole lot simpler
        
        if rhs.isPowerOfTwo {
            lhs &<<= rhs.mostSignificantBit
            return
        }
        
        var a = rhs
        var i = 0
        
        while (a[0] % 2) == 0 {
            a >>= 1
            i += 1
        }
        
        let originalLHS = lhs
        
        lhs &<<= i
        
        while a != 0 {
            
            a >>= 1
            i += 1
            
            if (a[0] % 2) == 1 {
                lhs &+= originalLHS &<< i
            }
        }
    }
    
    /**
     * Divides lhs by rhs
     */
    public static func /= (lhs: inout UBigNumber, rhs: UBigNumber) {
        assert(rhs != 0, "Cannot divide by 0")
        let divisor = rhs.erasingLeadingZeros
        
        if lhs == 0 {
            return
        }
        
        if rhs.isPowerOfTwo {
            lhs >>= rhs.mostSignificantBit
            return
        }
        
        var dividend = lhs
        var q: UBN = 0 // quotient
        var i = 0
        
        let dividendBitWidth = dividend.size * 64
        let divisorBitWidth  = divisor.mostSignificantBit
        let shiftedDivisor   = divisor << (dividendBitWidth - divisorBitWidth)
        
        while dividend >= divisor {
            i = 0
            while i <= (dividendBitWidth - divisorBitWidth) {
                let positionedDivisor = shiftedDivisor >> i
                let portionOfDividend = (dividend << i) >> (dividendBitWidth - divisorBitWidth)
                
                q <<= 1
                
                if portionOfDividend >= divisor {
                    dividend -= positionedDivisor
                    q += 1
                }
                
                i += 1
            }
        }
        
        lhs = q
        
    }
    
    public static func %= (lhs: inout UBigNumber, rhs: UBigNumber) {
        assert(rhs != 0, "Cannot divide by 0")
        let divisor = rhs.erasingLeadingZeros
        
        if lhs == 0 {
            return
        }
        
        
        let dividendBitWidth = lhs.size * 64
        let divisorBitWidth  = divisor.mostSignificantBit
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
        a &+= rhs
        return a
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
        a += rhs
        return a
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
        a -= rhs
        return a
    }
    
    /// Multiplies two BigNumbers
    ///
    /// - Parameters:
    ///     - lhs: A BigNumber to multiply
    ///     - rhs: A BigNumber to multiply
    ///
    /// - Returns: Product of ```lhs``` and ```rhs```
    public static func * (lhs: UBigNumber, rhs: UBigNumber) -> UBigNumber {
        var a = lhs
        a *= rhs
        return a
    }
    
    /// Multiplies two BigNumbers with no overflow handling
    ///
    /// - Parameters:
    ///     - lhs: A BigNumber to multiply
    ///     - rhs: A BigNumber to multiply
    ///
    /// - Returns: Product of ```lhs``` and ```rhs```
    public static func &* (lhs: UBigNumber, rhs: UBigNumber) -> UBigNumber {
        var a = lhs
        a &*= rhs
        return a
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
