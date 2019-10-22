//
//  BigNumber+Operations.swift
//  BigNumber
//
//  Created by Sylvan Martin on 9/1/19.
//  Copyright © 2019 Sylvan Martin. All rights reserved.
//

import Foundation

extension BigNumber: BinaryInteger {
    
    
    // MARK: - Casting
    
    static func matchSizes(a: inout BigNumber, b: inout BigNumber) {
        let size = maxOf(a.array.count, b.array.count)
        
        while a.size < size {
            a.array.append(0)
        }
        
        while b.size < size {
            b.array.append(0)
        }
    }
    
    // MARK: Range Operators
    
    /// Returns all values between two values, inclusive
    ///
    /// - Parameters:
    ///     - a: Lower bound
    ///     - b: Upper bound
    ///
    /// - Returns: An array of all values between ```a``` and ```b```
    public static func ... <RHS: BinaryInteger>(lhs: BigNumber, rhs: RHS) -> [BigNumber] {
        var range: [BigNumber] = []
        var lower = lhs
        
        while lower <= BN(rhs) {
            range.append(lower)
            lower += 1
        }
        return range
    }
    
    /// Returns all values between two values, excluding the upper bound
    ///
    /// - Parameters:
    ///     - a: Lower bound
    ///     - b: Upper bound
    ///
    /// - Returns: An array of all values between ```a``` and ```b```, excluding ```b```
    public static func ..< <RHS: BinaryInteger>(lhs: BigNumber, rhs: RHS) -> [BigNumber] {
        var range: [BigNumber] = []
        var lower = lhs
        
        while lower < BN(rhs) {
            range.append(lower)
            lower += 1
        }
        return range
    }
    
    // MARK: - Bitwise Operations
    
    /// One's compliment
    ///
    /// - Parameters:
    ///     - rhs: The BigNumber to get the compliment of
    ///
    /// - Returns: The binary compliment of the BigNumber
    public static prefix func ~ (rhs: BigNumber) -> BigNumber {
        return BigNumber( rhs.array.map { ~($0) } )
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
    public static func | <RHS>(lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        // get the larger BigNumber
        
        var a = lhs.keepingLeadingZeros
        var b = BN(rhs).keepingLeadingZeros
        
        matchSizes(a: &a, b: &b)
        
        // OR every UInt64 in a with b
        for i in 0..<a.size {
            a[i] |= b[i]
        }
        
        return a.erasingLeadingZeros
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
    public static func & <RHS>(lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        // get the larger BigNumber
        
        var a = lhs.keepingLeadingZeros
        var b = BN(rhs).keepingLeadingZeros
        
        matchSizes(a: &a, b: &b)
        
        // AND every UInt64 in a with b
        for i in 0..<a.size {
            a[i] &= b[i]
        }
        
        return a.erasingLeadingZeros
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
    public static func ^ <RHS>(lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        // get the larger BigNumber
        
        var a = ((lhs.size >= BN(rhs).size) ? lhs : BN(rhs)).keepingLeadingZeros
        var b = ((BN(rhs).size >  lhs.size) ? lhs : BN(rhs)).keepingLeadingZeros
        
        matchSizes(a: &a, b: &b)
        
        // XOR every UInt64 in a with b
        for i in 0..<a.size {
            a[i] ^= b[i]
        }
        
        return a.erasingLeadingZeros
    }
    
    /// Left bitshifts the given BigNumber by a given integer amount, with no overflow handling
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to bitshift
    ///     - rhs: Amount to bit shift
    ///
    /// - Returns: Exactly what you would expect
    static func &<< <RHS>(lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs.keepingLeadingZeros
        
        for _ in 0..<rhs {
            // left bit shift a by 1
            for i in (1..<a.array.count).reversed() {
                // get bit about to be discarded
                a[i] <<= 1
                a[i] += a[i-1] >> 63
            }
            a[0] <<= 1
        }
        
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
    public static func << <RHS>(lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs.keepingLeadingZeros
        a.array.append(0)
        
        // I know this isn't the most efficient way of doing this
        // I sorta just scrapped this together
        for _ in 0..<rhs {
            
            // left bit shift a by 1
            for i in (1..<a.array.count).reversed() {
                // get bit about to be discarded
                if a[i] >> 63 == 1 {
                    a.array.append(a[i] >> 63)
                }
                
                a[i] <<= 1
                a[i] += a[i-1] >> 63 // "pull" bit from previous
            }
            a[0] <<= 1
        }
        
        return a.erasingLeadingZeros
        
    }
    
    /// Right bitshifts the given BigNumber by a given integer amount
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to bitshift
    ///     - rhs: Amount to bit shift
    ///
    /// - Returns: Exactly what you would expect
    public static func >> <RHS>(lhs: BigNumber, rhs: RHS) -> BigNumber where RHS : BinaryInteger {
        var a = lhs.keepingLeadingZeros
        
        for _ in 0..<rhs {
            // right bit shift a by 1
            for i in 0..<(a.array.count-1) {
                a[i] >>= 1
                if (a[i] & (1 << 63)) != (a[i+1] & 1) {
                    a[i] ^= 1 << 63
                }
            }
            a[a.array.count-1] >>= 1
        }
        
        return a
        
    }
    
    // MARK: Compound Assignment Bitwise Operators
    
    /// Stores the result of performing a bitwise OR operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
    public static func |= <RHS>(a: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        let largerSize: Int = {
            let x = a.size
            let y = a.size
            return x >= y ? x : y
        }()
        
        for i in 0..<largerSize {
            
            // make sure lhs is a valid size so we can actually assign values
            while a.size < i {
                a.array.append(0x0)
            }
            
            // now do the OR!
            a[i] |= BN(rhs)[safe: i]
        }
    }
    
    /// Stores the result of performing a bitwise AND operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
    public static func &= <RHS>(a: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        let largerSize: Int = {
            let x = a.size
            let y = BN(rhs).size
            return x >= y ? x : y
        }()
        
        for i in 0..<largerSize {
            
            // make sure lhs is a valid size so we can actually assign values
            while a.size < i {
                a.array.append(0x0)
            }
            
            // now do the AND!
            a[i] &= BN(rhs)[safe: i] ?? 0x0
        }

    }
    
    /// Stores the result of performing a bitwise XOR operation on the two given
    /// values in the left-hand-side variable.
    ///
    /// - Parameters:
    ///   - lhs: A BigNumber value.
    ///   - rhs: Another BigNumber value.
//    @discardableResult
    public static func ^= <RHS>(a: inout BigNumber, rhs: RHS) where RHS : BinaryInteger /*-> BigNumber*/ {
        let largerSize: Int = {
            let x = a.size
            let y = BN(rhs).size
            return x >= y ? x : y
        }()
        
        for i in 0..<largerSize {
            
            // make sure lhs is a valid size so we can actually assign values
            while a.size < i {
                a.array.append(0x0)
            }
            
            // now do the XOR!
            a[i] ^= BN(rhs)[safe: i] ?? 0x0
        }
        
    }
    
    /// Left bitshifts a value by another, and stores the result in the left hand side variable, with no overflow handling
    ///
    /// - Parameters:
    ///     - a: value to left bitshift
    ///     - b: amoutnt by which to left bitshift
    public static func &<<= <RHS>(a: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        a.setShouldEraseLeadingZeros(to: false)
        
        for _ in 0..<rhs {
            // left bit shift a by 1
            for i in (1..<a.array.count).reversed() {
                // get bit about to be discarded
                a[i] <<= 1
                a[i] += a[i-1] >> 63
            }
            a[0] <<= 1
        }
        
        a.setShouldEraseLeadingZeros(to: false)
    }
    
    /// Left bitshifts a value by another, and stores the result in the left hand side variable
    ///
    /// - Parameters:
    ///     - a: value to left bitshift
    ///     - b: amoutnt by which to left bitshift
    public static func <<= <RHS>(a: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        a.setShouldEraseLeadingZeros(to: false)
        
        // I know this isn't the most efficient way of doing this
        // I sorta just scrapped this together
        for _ in 0..<rhs {
            
            // left bit shift a by 1
            for i in (1..<a.array.count).reversed() {
                // get bit about to be discarded
                if a[i] >> 63 == 1 {
                    a.array.append(a[i] >> 63)
                }
                
                a[i] <<= 1
                a[i] += a[i-1] >> 63 // "pull" bit from previous
            }
            a[0] <<= 1
        }
        
        a.setShouldEraseLeadingZeros(to: true)
    }
    
    /// Right bitshifts a value by another, and stores the result in the left hand side variable
    /// Currently, this only actually works when bitshifting by a number smaller than 64. :(
    ///
    /// - Parameters:
    ///     - a: value to right bitshift
    ///     - b: amoutnt by which to right bitshift
    public static func >>= <RHS>(a: inout BigNumber, rhs: RHS) where RHS : BinaryInteger {
        a.setShouldEraseLeadingZeros(to: false)
        
        for i in 0..<(a.array.count) {
            a[i] >>= rhs
            a[i] += a[safe: i+1] << (64 - rhs)
        }
        
//        for _ in 0..<rhs {
//            // right bit shift a by 1
//            for i in 0..<(a.array.count-1) {
//                a[i] >>= 1
//                if (a[i] & (1 << 63)) != (a[i+1] & 1) {
//                    a[i] ^= 1 << 63
//                }
//            }
//            a[a.array.count-1] >>= 1
//        }
        
        a.setShouldEraseLeadingZeros(to: true)
    }
    
    // TODO: Do bit shift operators
    
    // MARK: - Comparative Operators
    
    /// Compares two BigNumbers, returns true if they are equal
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to compare
    ///     - rhs: Another BigNumber to compare
    ///
    /// - Returns: True if they are equal, false if not
    public static func == (lhs: BigNumber, rhs: BigNumber) -> Bool {
        
        let a = lhs.erasingLeadingZeros
        let b = rhs.erasingLeadingZeros
        
        guard a.size == b.size else { return false }
        
        for i in 0..<a.size {
            if a[i] != b[i] {
                return false
            }
        }
        
        return true
    }
    
    /// Compares two BigNumbers and retuns true if they are not equal
    ///
    /// - Parameters:
    ///     - lhs: BigNumber to compare
    ///     - rhs: Another BigNumber to compare
    ///
    /// - Returns: True if they are equal, false if not
    public static func != (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return !(lhs == rhs)
    }
    
    /// Greater than operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if lhs > rpublic hs
    public static func > (lhs: BigNumber, rhs: BigNumber) -> Bool {
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
    /// - Returns: True if lhs < rhs
    public static func < (lhs: BigNumber, rhs: BigNumber) -> Bool {
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
    /// - Returns: Trpublic ue if lhs >= rpublic hs
    public static func >= (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return lhs > rhs || lhs == rhs
    }
    
    /// Less than or Equal to Operator
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: True if lhs <= rpublic hs
    public static func <= (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    
    // MARK: - Arithmetic Operators
    
    /// Adds two BigNumbers, with overflow allowed
    ///
    /// This won't add any elements to the BigNumber array
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber
    ///
    /// - Returns: Sum of lhs and rhs without overflow prevention
    public static func &+ (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var r = BigNumber(0).keepingLeadingZeros
        let a = lhs.keepingLeadingZeros
        let b = rhs.keepingLeadingZeros
        
        var carryOut: UInt64 = 0
        var carryIn:  UInt64 = 0
        
        let largerSize: Int = {
            let x = a.size
            let y = b.size
            return x >= y ? x : y
        }()
        
        for i in 0..<largerSize {
            r[zeroing: i] = a[zeroing: i] &+ b[zeroing: i]
            if r[i] < a[zeroing: i] {
                carryOut = 1
            }
            if carryIn != 0 {
                r[i] &+= 1
                if ( 0 == r[i]) {
                    carryOut = 1
                }
            }
            carryIn = carryOut
            carryOut = 0
        }
        
        return r.erasingLeadingZeros
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
    public static func + (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        
        var r = BigNumber(0).keepingLeadingZeros
        let a = lhs.keepingLeadingZeros
        let b = rhs.keepingLeadingZeros
        
        var carryOut: UInt64 = 0
        var carryIn:  UInt64 = 0
        
        let largerSize: Int = {
            let x = a.size
            let y = b.size
            return x >= y ? x : y
        }()
        
        for i in 0...largerSize {
            r[zeroing: i] = a[zeroing: i] &+ b[zeroing: i]
            if r[i] < a[zeroing: i] {
                carryOut = 1
            }
            if carryIn != 0 {
                r[i] &+= 1
                if ( 0 == r[i]) {
                    carryOut = 1
                }
            }
            carryIn = carryOut
            carryOut = 0
        }
        
        return r.erasingLeadingZeros
    }
    
    
    
    /// Subtraction
    ///
    /// - Parameters:
    ///     - lhs: BigNumber
    ///     - rhs: BigNumber to subtract from ```lhs```
    ///
    /// - Returns: Difference of ```lhs``` and ```rhs```
    public static func - (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        // cast smaller BigNumber to larger array
        //
        // note: in this operation, the numbers are treated as raw arrays, NOT BigNumber objects.
        // this is because a BigNumber will automatically get rid of leading zeros, which we actually need in order
        // to make sure the numbers have the same size of array
        
        var a = lhs.keepingLeadingZeros
        var b = rhs.keepingLeadingZeros
        
        // make sure both are the same size
        
        let size = maxOf(a.size, b.size)
        
        while a.size < size {
            a.array.append(0)
        }
        
        while b.size < size {
            b.array.append(0)
        }
        
        // Now do two's compliment subtraction and return
        return ((~b &+ 1) &+ a).erasingLeadingZeros
    }
    
    /// Multiplies two BigNumbers
    ///
    /// - Parameters:
    ///     - lhs: A BigNumber to multiply
    ///     - rhs: A BigNumber to multiply
    ///
    /// - Returns: Product of ```lhs``` and ```rhs```
    public static func * (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var (a, b, product) : (BigNumber, BigNumber, BigNumber) = (lhs.keepingLeadingZeros, rhs.keepingLeadingZeros, 0)
        
        matchSizes(a: &a, b: &b)
        
        var i = 0
        
        while ( b > 0 ) {
            if (b & 1 == 1) {
                product = product + a << i
            }
            
            i += 1
            b = b >> 1
        }
        
        return product.erasingLeadingZeros
    }
    
    /// Divides two BigNumbers
    ///
    /// - Parameters:
    ///     - lhs: A BigNumber to divide
    ///     - rhs: BigNumber to divide ```rhs``` by
    ///
    /// - Returns: Product of ```lhs``` and ```rhs```
    public static func / (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        
        assert(rhs != 0, "Cannot divide by 0")
        
        var (a, b) = (lhs.keepingLeadingZeros, rhs.keepingLeadingZeros)
        
        // make them have the same size
        let size = maxOf(a.size, b.size)
        
        while a.size < size {
            a.array.append(0)
        }
        
        while b.size < size {
            b.array.append(0)
        }
        
        // now do the division
        
        var (quotient, remainder) : (BigNumber, BigNumber) = (0, 0)
        
        for i in (0..<b.bitWidth).reversed() {
            quotient = quotient << 1
            remainder = remainder << 1
            
            remainder |= (a & (BigNumber(1) << i)) >> i
            
            if (remainder >= b) {
                remainder = remainder - b;
                quotient |= 1;
            }
        }
        
        return quotient
    }
    
    /// Modulo operation for two ```BigNumber```'s
    ///
    /// - Parameters:
    ///     - lhs: ```BigNumber``` to modulo by another ```BigNumber```
    ///     - rhs: ```BigNumber``` by which to modulo
    ///
    /// - Returns: ```lhs``` modulo ```rhs```
    public static func % (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        assert(rhs != 0, "Cannot divide by 0")
        
        var (a, b) = (lhs.keepingLeadingZeros, rhs.keepingLeadingZeros)
        
        matchSizes(a: &a, b: &b)
        
        // now do the division
        
        var remainder: BigNumber = 0
        
        for i in (0..<b.bitWidth).reversed() {
            remainder = remainder << 1
            
            remainder |= (a & (BigNumber(1) << i)) >> i
            
            if (remainder >= b) {
                remainder = remainder - b;
            }
        }
        
        return remainder
    }
    
    // MARK: Compound Assignment Arithmetic Operators
    
    /// Adds two BigNumbers and assigns the sum to the left operand
    ///
    /// This will add elements to the array if needed
    ///
    /// - Parameters:
    ///     - a: BigNumber to add and also the variable to store the result
    ///     - rhs: BigNumber to add to ```a```
    ///
    /// - Returns: Sum of ```a``` and ```rhs```
    public static func += (a: inout BigNumber, rhs: BigNumber) {
        a = a + rhs
    }
    
    public static func -= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs = lhs - rhs
    }
    
    public static func *= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs = lhs * rhs
    }
    
    public static func /= (lhs: inout BigNumber, rhs: BigNumber) {
        lhs = lhs / rhs
    }
    
    public static func %= (lhs: inout BigNumber, rhs: BigNumber) {
        assert(rhs != 0, "Cannot divide by 0")
        
        let a = lhs
        var b = rhs.keepingLeadingZeros
        
        matchSizes(a: &lhs, b: &b)
        
        // now do the division
        
        for i in (0..<b.bitWidth).reversed() {
            lhs <<= 1
            
            lhs |= (a & (BigNumber(1) << i)) >> i
            
            if (lhs >= b) {
                lhs -= b;
            }
        }
        
        lhs.setShouldEraseLeadingZeros(to: true)
    }
    
    
    
    // MARK: Private functions
    
    /// Returns the maximum of two comparables
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
